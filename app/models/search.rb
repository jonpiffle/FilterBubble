require 'net/http'
require "open-uri"
require 'json'

class Search
	@@proxies = [
		#["197.162.114.223", "80", "Egypt", ""],
		["67.195.194.149", "80", "United States", "California", "us"],
		["202.169.50.5", "8080", "Indonesia", "Jakarta Raya", "id"],
		["121.35.157.184", "8888", "China", "Guangdong", "cn"],
		#["14.102.62.99", "8080", "India", "Delhi"],
		["27.131.190.178", "8080", "Thailand", "", "th"],
		#["123.134.94.3", "80", "China", "Shandong"],
		["61.110.196.166", "80", "Korea", "Seoul", "kp"],
		["195.222.85.227", "3128", "Belarus", "Minsk", "be"],
		["189.90.240.41", "3128", "Brazil", "Minas Gerais", "br"],
		["83.222.60.214", "8080", "Luxembourg", "Luxembourg", "lu"],
		#["85.114.141.191", "80", "Germany", ""],
		["92.46.119.60", "3128", "Kazakhstan", "Astana", "kz"],
		["113.164.1.40", "3128", "Vietnam", "Dac Lac", "vn"],
		#["151.97.0.65", "3128", "Italy", "Sicilia"],
		["31.6.70.74", "8080", "Poland", "", "pl"],
		["217.26.9.26", "3128", "Russia", "Moscow City", "ru"],
		["84.50.44.92", "3128", "Estonia", "Harjumaa", "ee"],
		#["198.143.1.163", "7808", "United States", "New York"],
		#["72.29.101.11", "8089", "United States", "Texas"],
		["81.218.116.230", "3128", "Israel", "", "il"],
		["41.222.196.52", "8080", "Congo", "Kinshasa", "cg"],
		["147.102.3.116", "443", "Greece", "Attiki", "gr"],
		#["190.124.165.194", "3128", "Honduras", ""],
		["62.201.220.78", "80", "Iraq", "", "iq"],
		["85.185.45.91", "3128", "Iran", "", "ir"]
	]

	@@proxies = @@proxies.map {|p| Proxy.new(p[0], p[1], p[2], p[3], p[4])}
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
		
		threads = []
		results = {}
		@@proxies.sample(@@SAMPLE_NUM).each do |p|
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
