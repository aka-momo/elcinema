require 'open-uri'
require 'nokogiri'
require 'json'

module Elcinema
  module Scrapper
    class Base
      BASE_URL = 'http://www.elcinema.com/en'.freeze

      def self.open_html(base_url: BASE_URL, path: '', params: {})
        url = prepare_url(base_url: base_url, path: path, params: params)
        Nokogiri::HTML(open_url(url))
      end

      def self.open_json(base_url: BASE_URL, path: '', params: {})
        url = prepare_url(base_url: base_url, path: path, params: params)
        JSON.parse(open_url(url).read)
      end

      def self.prepare_url(base_url: BASE_URL, path: '', params: {})
        raw_params = params
                     .map { |key, value| "#{key}=#{URI.encode(value.to_s)}" }
                     .join('&')
        url = base_url
        url += "/#{path}" unless path.empty?
        url += "?#{raw_params}" unless raw_params.empty?
        url
      end

      def self.open_url(url)
        Elcinema.logger.debug { "Fetching: #{url}" }
        open(url)
      end
    end
  end
end
