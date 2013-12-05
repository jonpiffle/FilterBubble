class ProxyCollection
	@@us_filename = 'us_working_proxies.txt'
	@@non_us_filename = 'non_us_working_proxies.txt'

	def initialize(n)
		non_us_file = File.join(Rails.root, @@non_us_filename)
		us_file = File.join(Rails.root, @@us_filename)

		@proxies = []
		non_us_file = File.readlines(non_us_file)
		non_us_file.sample(2*n).each do |proxy|
			proxy = proxy.strip.split(":")
			proxy = Proxy.new(proxy[0],proxy[1])
			@proxies.push(proxy)
		end
		us_file = File.readlines(us_file)
		proxy = us_file.sample
		proxy = proxy.strip.split(":")
		proxy = Proxy.new(proxy[0],proxy[1])
		@proxies.push(proxy)

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