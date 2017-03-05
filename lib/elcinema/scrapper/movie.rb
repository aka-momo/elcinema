require 'json'

module Elcinema
  module Scrapper
    class Movie < Elcinema::Model
      ## Extend
      include Elcinema::Scrapper

      ## Attributes
      attr_accessor :document, :title

      BASE_URL = 'http://www.elcinema.com/en/now/eg'.freeze
      OMDB_URL = 'http://www.omdbapi.com/?y=2017&t='.freeze

      ## Methods
      def titles
        prepare_document(path: BASE_URL)
        @document.css('div.row h3 a').map(&:content)
      end

      def omdb
        uri = URI(OMDB_URL + @title)
        tmp = JSON.parse(Net::HTTP.get(uri))
        return nil if tmp['Response'] == 'Error'
        tmp
      rescue
        return true
      end
    end
  end
end
