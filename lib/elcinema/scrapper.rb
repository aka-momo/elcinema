## Require nokogiri
require 'nokogiri'
require 'open-uri'

module Scrapper
  # Prepare Document
  def prepare_document(path:, params: {})
    url = path + '?'
    params.each { |key, value| url += "#{key}=#{value}&" }
    @document = Nokogiri::HTML(open(url))
  end
end
