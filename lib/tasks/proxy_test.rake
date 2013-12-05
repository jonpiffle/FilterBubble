require 'net/http'
require "open-uri"
require 'json'
require 'timeout'
require_relative '../../app/models/ip_geo_info'

task :test_proxies do
	filename = 'us_working_proxies.txt'
	file = File.join(Rails.root, filename)
	@proxies = []
	threads = []
	proxies = File.readlines(file)
	non_us_file = File.new("non_us_working_proxies.txt", "a")
	us_file = File.new("us_working_proxies.txt", "a")

	proxies.each do |p|
		threads << Thread.new do
			puts p
			begin
				timeout(10) {
					sleep 1 until results = open("http://www.yahoo.com", :proxy=>"http://#{p.strip!}").read rescue nil
					test = true
					country_code = IPGeoInfo.new(p.split(':')[0]).country_code
				}
				test = true
				country_code = IPGeoInfo.new(p.split(':')[0]).country_code
			rescue Timeout::Error
				test = false
			end
			puts test
			if test
				puts country_code
				country_code == "US" ? us_file.puts(p) : non_us_file.puts(p)
			end
		end
	end
	threads.each { |thread| thread.join }
	non_us_file.close
	us_file.close
end
