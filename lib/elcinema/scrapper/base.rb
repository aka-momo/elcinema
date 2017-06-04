require 'open-uri'
require 'nokogiri'
require 'json'

module Elcinema
  module Scrapper
    class Base
      AN_HOUR  = 3_600
      META_URL = 'https://api.themoviedb.org/3'.freeze
      TRIALS   = 3

      ## Methods
      def self.open_html(base_url = self.base_url, path: '', params: {})
        url = prepare_url(base_url, path: path, params: params)
        Nokogiri::HTML(open_url(url))
      end

      def self.open_json(base_url = self.base_url, path: '', params: {})
        url = prepare_url(base_url, path: path, params: params)
        JSON.parse(open_url(url).read)
      end

      def self.prepare_url(base_url = self.base_url, path: '', params: {})
        raw_params = params
                     .map { |key, value| "#{key}=#{URI.encode(value.to_s)}" }
                     .join('&')
        url = base_url
        url += "/#{path}" unless path.empty?
        url += "?#{raw_params}" unless raw_params.empty?
        url
      end

      def self.open_url(url, trials: TRIALS, delay: 1, silent: false)
        state = 'Fetching'
        trials.downto(1) do |n|
          begin
            ::Elcinema.logger.debug { "#{state}: #{url}" }
            return open(url)
          rescue Errno::ECONNRESET, Errno::ECONNREFUSED => e
            fail e unless silent || n > 1

            state = "Retry ##{TRIALS + 1 - n}"
            sleep delay
          end
        end
      end

      protected

      def self.base_url
        raise NotImplementedError, '.base_url has to be implemented by subclasses'
      end
    end
  end
end
