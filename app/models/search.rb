require 'net/http'
require "open-uri"
require 'json'

class Search
	@@SAMPLE_NUM = 10

	def self.get_results(query, page=1)
		start = 1 + 10*(page-1)
		url = "https://www.googleapis.com/customsearch/v1"
		uri = URI(url)
		params = {
			:key => "AIzaSyB0EwGLXaN8jI9CjEaobtgRP0vuHUwwqqI",
			:cx => "002901020921331500559:4dllxa3u2gs",
			:q => query,
			:lr => "lang_en",
			:start => start}

		proxies = ProxyCollection.new(@@SAMPLE_NUM)
		return proxies.search(uri, params)
	end
end
