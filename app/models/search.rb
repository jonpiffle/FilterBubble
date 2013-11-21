require 'net/http'
require 'json'

class Search
	def self.get_results(query)
		url = "https://www.googleapis.com/customsearch/v1"
		uri = URI(url)
		params = {
			:key => "AIzaSyB0EwGLXaN8jI9CjEaobtgRP0vuHUwwqqI",
			:cx => "002901020921331500559:4dllxa3u2gs",
			:q => query}
		uri.query = URI.encode_www_form(params)
		res = Net::HTTP.get_response(uri)
		return res.body
	end
end
