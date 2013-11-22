require 'net/http'
require "open-uri"
require 'json'

class Search
	def self.get_results(query)
		url = "https://www.googleapis.com/customsearch/v1"
		uri = URI(url)
		params = {
			:key => "AIzaSyB0EwGLXaN8jI9CjEaobtgRP0vuHUwwqqI",
			:cx => "002901020921331500559:4dllxa3u2gs",
			:q => query,
			:lr => "lang_en"}

		uri.query = URI.encode_www_form(params)
		sleep 1 until results = open(uri.to_s, :proxy=>"http://109.224.12.234:8080").read rescue nil
		results = JSON::parse(results)
		return results
	end

	def self.test_proxy
		url = "https://www.googleapis.com/customsearch/v1?key=AIzaSyB0EwGLXaN8jI9CjEaobtgRP0vuHUwwqqI&cx=002901020921331500559%3A4dllxa3u2gs&q=test&lr=lang_en"
		sleep 10 until results = open(url, :proxy=>"http://77.120.126.35:3128").read rescue nil
		results = JSON::parse(results.body)
	end
end
