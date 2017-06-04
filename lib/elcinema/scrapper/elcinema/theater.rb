module Elcinema
  module Scrapper
    module Elcinema
      class Theater < ::Elcinema::Scrapper::Theater
        extend Base

        ## Methods
        def self.find(id)
          page = open_html(path: "theater/#{id}")

          {}.tap do |theater|
            theater[:id]        = id.to_s
            theater[:name]      = page.css('.jumbo .left').first.text.strip
            theater[:image_url] = page.css('.intro-box img').first[:src]
            theater[:address]   = page.css('ul.unstyled.no-margin li:first-child').first.text.strip

            theater[:movies]    = page.css('#theater-showtimes-container h3 a').map do |elm|
              {}.tap do |movie|
                movie[:id]    = elm[:href][/\d+/]
                movie[:title] = elm.text.strip
              end
            end
          end
        end

        def self.load(page: 1)
          page = open_html(path: 'theater/1/1', params: { page: page })

          {}.tap do |data|
            data[:theaters] = page.css('.jumbo-theater > a:nth-child(2)').map do |elm|
              {}.tap do |theater|
                theater[:id]   = elm[:href][/\d+/]
                theater[:name] = elm.text.strip
              end
            end

            data[:has_more] = page.css('.pagination li.current + li:not(.arrow)').any?
          end
        end
      end
    end
  end
end
