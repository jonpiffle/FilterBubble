require 'net/http'
require "open-uri"
require 'json'
require 'timeout'

class Proxy
	attr_reader :ip, :port, :country, :region, :country_code
	def initialize(ip, port, country, region, country_code)
		@ip = ip
		@port = port
		@country = country
		@region = region
		@country_code = country_code
	end

	def destination
		"http://#{@ip}:#{@port}"
	end

	def location
		@region.blank? ? "#{@country}" : "#{@region}, #{@country}"
	end

	def search(uri, params)
		puts "#{location} started"
		params[:gl] = @country_code
		uri.query = URI.encode_www_form(params)
		timeout(20) { 
			sleep 1 until results = open(uri.to_s, :proxy=>destination).read rescue nil
			results = JSON::parse(results)
			puts "#{location} finished"
			return results
		}
	end
end