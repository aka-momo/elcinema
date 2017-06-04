module Elcinema
  module Scrapper
    module Vox
      class Movie < ::Elcinema::Scrapper::Movie
        extend Base

        ## Methods
        def self.find(id, with_meta: false, with_trailer: false, with_times: false)
          page = open_html(path: "movies/#{id}")

          {}.tap do |movie|
            movie[:id]    = id.to_s
            movie[:title] = page.css('h1').first.text.strip
            movie[:year]  = page.css('aside p:nth-child(3)').first.text[/\d+$/]

            if with_meta
              meta = meta_for(movie[:title], year: movie[:year])
              movie.merge!(meta) unless meta.nil?
            end

            if with_trailer
              movie[:trailer_url] = page.css('.trailer iframe').first[:src]
            end

            movie[:times] = times_for(id) if with_times
          end
        end

        def self.times_for(id)
          page = open_html(path: "movies/#{id}")

          page.css('.dates h3').flat_map do |elm|
            elm.next.next.css('> li').map do |sub|
              {}.tap do |time|
                time[:theater_id] = "#{elm.text.strip.downcase.gsub(/\s+/, '-')}:#{sub.css('strong').first.text.strip.downcase}"
                time[:times]      = format_times(sub.css('a').map(&:text))
              end
            end
          end
        end

        def self.load(page: 1)
          page = open_html(path: 'showtimes', params: { o: :az, page: page })

          {}.tap do |data|
            data[:movies] = page.css('.movie-compare').map do |elm|
              {}.tap do |movie|
                movie[:id]    = elm[:'data-slug']
                movie[:title] = elm.css('h2').first.text.strip
              end
            end

            data[:has_more] = false
          end
        end
      end
    end
  end
end
