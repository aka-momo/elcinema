module Elcinema
  module Scrapper
    class Movie < Base
      ## Constants
      OMDB_URL = 'http://www.omdbapi.com/'.freeze
      AN_HOUR  = 3_600

      ## Methods
      def self.all(with_details: false)
        page = 1

        [].tap do |movies|
          loop do
            data = load(page: page)

            data[:movies].each do |movie|
              movie = find(movie[:id], with_omdb: true, with_trailer: true, with_times: true) if with_details
              movies << movie unless movie.nil?
            end

            break unless data[:has_more]

            page += 1
          end
        end
      end

      def self.find(id, with_omdb: false, with_trailer: false, with_times: false)
        page = open_html(path: "work/#{id}")

        {}.tap do |movie|
          movie[:id]    = id.to_s
          movie[:title] = page.css('.jumbo .left').first.text.strip
          movie[:year]  = page.css('.jumbo .left').last.text[/\d+/]

          if with_omdb
            omdb = omdb_for(movie[:title], year: movie[:year])
            movie.merge!(omdb) unless omdb.nil?
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

      def self.omdb_for(title, year: Time.current.year)
        {}.tap do |movie|
          title = title.split(/[\:\()]/).first.strip

          json = [0, -1, 1].inject({}) do |_, offset|
            params = { t: title, y: year.to_i + offset }
            json = open_json(base_url: OMDB_URL, params: params)
            next {} if json['Response'] == 'False'

            movie[:year] = params[:y].to_s
            break json
          end

          sanitized    = ->(value)     { value && value != 'N/A' }
          parse_number = ->(attr, key) { movie[attr] = (json[key][/\d+/]      if sanitized.call(json[key])) }
          parse_string = ->(attr, key) { movie[attr] = (json[key]             if sanitized.call(json[key])) }
          parse_array  = ->(attr, key) { movie[attr] = (json[key].split(', ') if sanitized.call(json[key])) }

          { runtime:    'Runtime' }.each(&parse_number)
          { awards:     'Awards',
            plot:       'Plot',
            poster_url: 'Poster',
            rating:     'imdbRating' }.each(&parse_string)
          { actors:     'Actors',
            directors:  'Director',
            genres:     'Genre' }.each(&parse_array)
        end
      end

      def self.times_for(id)
        page = open_html(path: "work/#{id}/theater")

        page.css('.tabs-content .active .row').map do |elm|
          {}.tap do |time|
            time[:theater_id] = elm.css('.large-4 a:last-child').first[:href][/\d+/]
            time[:times]      = elm.css('.large-6 li:not(:last-child)').map(&:text)
                                   .uniq
                                   .map { |t| Time.parse(t.gsub(/\s+/, ' ')) - 10 * AN_HOUR }
                                   .map { |t| t.strftime('%I:%M %p') }
                                   .map { |t| Time.parse(t) }
                                   .sort
                                   .map { |t| (t + 10 * AN_HOUR).strftime('%I:%M %p') }
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
