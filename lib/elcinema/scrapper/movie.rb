module Elcinema
  module Scrapper
    class Movie < Base
      ## Constants
      META_URL = 'https://api.themoviedb.org/3'.freeze
      AN_HOUR  = 3_600

      ## Methods
      def self.all(with_details: false)
        page = 1

        [].tap do |movies|
          loop do
            data = load(page: page)

            data[:movies].each do |movie|
              movie = find(movie[:id], with_meta: true, with_trailer: true, with_times: true) if with_details
              movies << movie unless movie.nil?
            end

            break unless data[:has_more]

            page += 1
          end
        end
      end

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

      def self.meta_for(title, year: Time.current.year)
        api_key = ENV.fetch('TMDB_API_KEY') { return {} }

        {}.tap do |movie|
          title = title.split(/[\:\()]/).first.strip

          json = [0, -1, 1].inject({}) do |_, offset|
            params = { api_key: api_key, query: title, year: year.to_i + offset }
            json = open_json(base_url: META_URL, path: 'search/movie', params: params)
            next {} if json['total_results'] == 0

            movie_id = json['results'].first['id']
            params = { api_key: api_key, append_to_response: 'credits' }
            json = open_json(base_url: META_URL, path: "movie/#{movie_id}", params: params)

            movie[:year] = (year.to_i + offset).to_s
            break json
          end

          return if json.empty?

          sanitized    = ->(value)     { value && value != 'N/A' }
          parse_number = ->(attr, key) { movie[attr] = (json[key][/\d+/]      if sanitized.call(json[key])) }
          parse_string = ->(attr, key) { movie[attr] = (json[key]             if sanitized.call(json[key])) }
          parse_array  = ->(attr, key) { movie[attr] = (json[key].split(', ') if sanitized.call(json[key])) }

          movie['poster_url'] = "https://image.tmdb.org/t/p/w780#{json['poster_path']}"
          movie['actors']     = json['credits']['cast'].take(3).map { |c| c['name'] }
          movie['directors']  = json['credits']['crew'].select { |c| c['job'] == 'Director' }.take(3).map { |c| c['name'] }
          movie['genres']     = json['genres'].take(3).map { |c| c['name'] }

          { runtime:    'runtime',
            plot:       'overview',
            rating:     'vote_average' }.each(&parse_string)
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
