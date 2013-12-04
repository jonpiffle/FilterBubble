class ProxyCollection
	@@filename = 'proxies.txt'

	def initialize(n)
		file = File.join(Rails.root, 'app', 'models', @@filename)
		@proxies = []
		country_codes = []
		while @proxies.length < 10
			proxy = File.readlines(file).sample
			proxy = proxy.strip.split(":")
			proxy = Proxy.new(proxy[0],proxy[1])
			if proxy.country_code && !country_codes.include?(proxy.country_code)
				@proxies.push(proxy)
				country_codes.push(proxy.country_code)
			end
		end
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