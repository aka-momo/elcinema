module Elcinema
  module Scrapper
    class Theater < Elcinema::Model
      ## Extend
      include Elcinema::Scrapper

      ## Attributes
      attr_accessor :id, :document

      BASE_URL = 'http://www.elcinema.com/en/theater/'.freeze

      ## Methods
      def execute
        prepare_document(path: theater_url(@id))
        theater_name = @document.css('div.panel.jumbo span.left').first.content
        theater_location = @document.css('ul.unstyled.no-margin li').first.content.gsub(/^[\\n\s]*|[\\n\s]*$/, '')
        theater = Elcinema::Theater.new(name: theater_name, location: theater_location, movies: [])
        @document.css('div.boxed-0 > div.row')[1..-1].each do |row|
          theater.movies << exctact_movie(row)
        end
        theater
      end

      private

      def exctact_movie(row)
        img    = row.css('a img').first['src']
        title  = row.css('li h3 a').first.content.gsub(/^[\\n\s]*|[\\n\s]*$/, '')
        actors = row.css('li ul.list-separator a').map(&:content).join(', ')
        plot   = row.css('li p.no-margin').first.children.reject { |x| x.name == 'a' }.map(&:content).join
        times  = row.css('div.text-center li strong').map { |x| x.content[0..-2] }
        Elcinema::Movie.new(image_url: img, title: title, actors: actors, plot: plot, times: times)
      end

      def theater_url(id)
        BASE_URL + id
      end
    end
  end
end
