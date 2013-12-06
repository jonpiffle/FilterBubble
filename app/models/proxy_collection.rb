require 'net/http'
require "open-uri"
require 'json'
require 'timeout'

class ProxyCollection
	@@us_filename = 'us_working_proxies.txt'
	@@non_us_filename = 'non_us_working_proxies.txt'

	def initialize(n)
		non_us_file = File.join(Rails.root, @@non_us_filename)
		us_file = File.join(Rails.root, @@us_filename)

		@proxies = []
		threads = []
		non_us_file = File.readlines(non_us_file)
		non_us_file.sample(2*n).each do |proxy|
			threads << Thread.new do
				proxy = proxy.strip.split(":")
				proxy = Proxy.new(proxy[0],proxy[1])
				@proxies.push(proxy)
			end
		end
		us_file = File.readlines(us_file)
		us_file.sample(2).each do |proxy|
			threads << Thread.new do
				proxy = proxy.strip.split(":")
				proxy = Proxy.new(proxy[0],proxy[1])
				@proxies.push(proxy)
			end
		end
		threads.each { |thread| thread.join }

		@proxies.keep_if {|p| !p.country_code.blank?}
		@proxies.uniq! {|p| p.country_code}
		@proxies = @proxies.take(n)
		puts @proxies.map(&:to_s)
	end	

	def search(uri, params)
		threads = []
		results = {}
		@proxies.each do |p|
			threads << Thread.new do
				begin
					p.search(uri, params)['items'].each.with_index(1) do |item, i|
						url = item['link']
						if results.include?(url)
							results[url][:locations].push(p.location)
							results[url][:score] += 1/i.to_f
						else
							results[url] = {:item => item, :locations => [p.location], :score => 1/i.to_f}
						end
					end
				rescue
					puts "#{p.location} timed out"
				end
			end
		end
		threads.each { |thread| thread.join }
		return results.values.sort {|a, b| b[:score] <=> a[:score]}
	end
end

class Proxy
	attr_reader :ip, :port, :country, :country_code
	def initialize(ip, port, loc=true)
		@ip = ip
		@port = port
		get_location_data if loc
	end

	def destination
		"http://#{@ip}:#{@port}"
	end

	def location
		@country
	end

	def get_location_data
		ip_geo_info = IPGeoInfo.new(@ip)
		@country = ip_geo_info.country_name
		@country_code = ip_geo_info.country_code.downcase
	end

	def to_s
		"#{@ip}:#{@port}, #{@country}, #{@country_code}"
	end

	def search(uri, params)
		puts "#{location} started"
		params[:gl] = @country_code
		uri.query = URI.encode_www_form(params)
		timeout(15) { 
			sleep 1 until results = open(uri.to_s, :proxy=>destination).read rescue nil
			results = JSON::parse(results)
			puts "#{location} finished"
			return results
		}
	end
end

class IPGeoInfo
  attr_accessor :country_code, :country_name
  def initialize ( ip_address )
    @ip = ip_address
    @query_url = create_query_url
    @results = get_json_response
    @country_code = @results['country_code']
    @country_name = @results['country_name']
  end
  
  def create_query_url
    'http://freegeoip.net/json/' + @ip
  end
  
  def get_json_response
    begin
      response = Net::HTTP.get_response(URI.parse(@query_url))
      JSON.parse(response.body)
    rescue
      {'country_code' => "", 'country_name' => ''}
    end
  end
end
