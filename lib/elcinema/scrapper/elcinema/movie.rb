module Elcinema
  module Scrapper
    module Elcinema
      class Movie < ::Elcinema::Scrapper::Movie
        extend Base

        ## Methods
        def self.find(id, with_meta: false, with_trailer: false, with_times: false)
          page = open_html(path: "work/#{id}")

          {}.tap do |movie|
            movie[:id]    = id.to_s
            movie[:title] = page.css('.jumbo .left').first.text.strip
            movie[:year]  = page.css('.jumbo .left').last.text[/\d+/]

            if with_meta
              meta = meta_for(movie[:title], year: movie[:year])
              movie.merge!(meta) unless meta.nil?
            end

            trailer_id = page.css('.large-3 .blue').first
            if with_trailer && !trailer_id.nil?
              trailer_id = trailer_id[:href][/\d+/]
              trailer    = Video.find(trailer_id)
              movie[:trailer_url] = trailer[:url]
            end

            movie[:times] = times_for(id) if with_times
          end
        end

        def self.times_for(id)
          page = open_html(path: "work/#{id}/theater")

          page.css('.tabs-content .active .row').map do |elm|
            {}.tap do |time|
              time[:theater_id] = elm.css('.large-4 a:last-child').first[:href][/\d+/]
              time[:times]      = format_times(elm.css('.large-6 li').map(&:text))
            end
          end
        end

        def self.load(page: 1)
          page = open_html(path: 'now/eg', params: { page: page })

          {}.tap do |data|
            data[:movies] = page.css('h3 a:not(:empty)').map do |elm|
              {}.tap do |movie|
                movie[:id]    = elm[:href][/\d+/]
                movie[:title] = elm.text.strip
              end
            end

            data[:has_more] = page.css('.pagination li.current + li:not(.arrow)').any?
          end
        end
      end
    end
  end
end
