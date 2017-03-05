module Elcinema
  class Movie < Model
    ## Attributes
    attr_accessor :image_url, :title, :actors, :plot, :times
    attr_accessor :awards, :director, :genres, :runtime, :year, :invalid, :rating

    ## Methods
    def self.details_from_theater(theater_id, target_title)
      Elcinema::Theater.find(theater_id).movies.find { |m| m.title == target_title }
    rescue
      nil
    end

    def self.details(target_title)
      movie = Elcinema::Movie.new(title: target_title)
      movie.update_from_omdb
      movie.clean_null_params
      movie
    end

    def self.trending
      movie_scrapper = Elcinema::Scrapper::Movie.new
      movie_scrapper.titles.map { |t| details(t) }
    end

    def update_from_omdb
      movie_scrapper = Elcinema::Scrapper::Movie.new(title: title)
      omdb_data  = movie_scrapper.omdb
      @title     = title
      @year      = omdb_data['Year']
      @runtime   = omdb_data['Runtime']
      @genres    = omdb_data['Genre'].split(', ')
      @actors    = omdb_data['Actors'].split(', ')
      @director  = omdb_data['Director']
      @plot      = omdb_data['Plot']
      @awards    = omdb_data['Awards'].split(', ')
      @image_url = omdb_data['Poster']
      @rating = omdb_data['imdbRating']
      clean_null_params
    rescue
      @invalid = true
    end

    private

    def clean_null_params
      instance_variables.each do |v|
        var = send(v[1..-1])
        case var.class
        when String
          send("#{v[1..-1]}=", nil) if var == 'N/A'
        when Array
          send("#{v[1..-1]}=", nil) if var.first == 'N/A'
        end
      end
    end
  end
end
