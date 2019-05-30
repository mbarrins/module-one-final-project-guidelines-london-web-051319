class ApiData
  attr_reader :url, :api_key, :data

  def initialize(url:, search_string: nil, api_key: nil, page_no: 0, page_size: 10)
    @url = url
    @api_key = api_key
  end

  def get_data
    @data = JSON.parse(RestClient.get(self.url << "apikey=#{api_key}"))
  end

end