require 'rubygems'
require 'json'
require 'net/http'

class IPGeoInfo
  attr_accessor :country_code, :country_name
  def initialize ( ip_address )
    @ip = ip_address
    @query_url = create_query_url
    @results = get_json_response
    @country_code = @results['country_code']
    @country_name = @results['country_name']
  end
  
  def create_query_url
    'http://freegeoip.net/json/' + @ip
  end
  
  def get_json_response
    begin
      response = Net::HTTP.get_response(URI.parse(@query_url))
      JSON.parse(response.body)
    rescue
      {'country_code' => "", 'country_name' => ''}
    end
  end
end
