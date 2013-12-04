class HSLA
	@@hsla = [
				[0, 100, 50, 1],
				[25, 100, 50, 1],
				[55, 100, 50, 1],
				[80, 100, 50, 1],
				[125, 100, 50, 1],
				[160, 100, 50, 1],
				[190, 100, 50, 1],
				[220, 100, 50, 1],
				[270, 100, 50, 1],
				[300, 100, 50, 1]
			]

	def self.hsla_map(array=[])
		hsla_map = {}
		array.each_with_index {|el, i| hsla_map[el] = @@hsla[i % @@hsla.length]}
		hsla_map.each {|key,array| hsla_map[key] = hsla_to_css(array)}
		hsla_map
	end

	def self.hsla_to_css(hsla)
		return "hsla(#{hsla[0]},#{hsla[1]}%, #{hsla[2]}%, #{hsla[3]})"
	end
end