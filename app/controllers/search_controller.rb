class SearchController < ApplicationController
  	def index
	end

	def results
		@query = params[:search]
		@page = params[:page].to_i
		s = Search.get_results(@query, @page)
		@results = s
		@locations = @results.map {|result| result[:locations]}.inject(:+) || []
		@locations.uniq! if @locations
		@hsla_map = HSLA.hsla_map(@locations)
	end
end
