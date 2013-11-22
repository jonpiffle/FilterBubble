class SearchController < ApplicationController
  	def index
	end

	def results
		@query = params[:search]
		s = Search.get_results(@query)
		@results = s['items']
	end
end
