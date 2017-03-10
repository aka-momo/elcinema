module Elcinema
  module Scrapper
    class Video < Base
      def self.find(id)
        page = open_html(path: "video/#{id}")

        {}.tap do |video|
          video[:url] = page.css('.flex-video iframe').first[:src]
        end
      end
    end
  end
end
