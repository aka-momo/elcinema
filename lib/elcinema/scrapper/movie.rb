module Elcinema
  module Scrapper
    class Movie < Base
      AN_HOUR  = 3_600
      META_URL = 'https://api.themoviedb.org/3'.freeze

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

      def self.meta_for(title, year: Time.current.year)
        api_key = ENV.fetch('TMDB_API_KEY') { return {} }

        {}.tap do |movie|
          title = title.split(/[\:\()]/).first.strip

          json = [0, -1, 1].inject({}) do |_, offset|
            params = { api_key: api_key, query: title, year: year.to_i + offset }
            json = open_json(META_URL, path: 'search/movie', params: params)
            next {} if json['total_results'] == 0

            movie_id = json['results'].first['id']
            params = { api_key: api_key, append_to_response: 'credits' }
            json = open_json(META_URL, path: "movie/#{movie_id}", params: params)

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

      def self.format_times(times)
        times.uniq
             .map { |t| Time.parse(t.gsub(/\s+/, ' ')) - 10 * AN_HOUR rescue nil }
             .compact
             .map { |t| t.strftime('%I:%M %p') }
             .map { |t| Time.parse(t) }
             .sort
             .map { |t| (t + 10 * AN_HOUR).strftime('%I:%M %p') }
      end
    end
  end
end
