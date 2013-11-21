class SearchController < ApplicationController
  	def index
	end

	def search
		s = Search.get_results(params[:search])
		puts s
		redirect_to action: 'index'
	end
end
