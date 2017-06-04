module Elcinema
  module Scrapper
    module Elcinema
      class Video < ::Elcinema::Scrapper::Base
        extend Base

        ## Methods
        def self.find(id)
          page = open_html(path: "video/#{id}")

          {}.tap do |video|
            video[:url] = page.css('.flex-video iframe').first[:src]
          end
        end
      end
    end
  end
end
