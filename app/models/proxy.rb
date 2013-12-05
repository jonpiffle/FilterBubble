require 'net/http'
require "open-uri"
require 'json'
require 'timeout'

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