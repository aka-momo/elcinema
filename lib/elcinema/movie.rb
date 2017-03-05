module Elcinema
  class Movie < Model
    ## Attributes
    attr_accessor :image_url, :title, :actors, :plot, :times
    attr_accessor :awards, :director, :genre, :runtime, :year, :invalid

    ## Methods
    def self.details_from_theater(theater_id, target_title)
      Elcinema::Theater.find(theater_id).movies.find { |m| m.title == target_title }
    rescue
      nil
    end

    def self.details(target_title)
      movie = Elcinema::Movie.new(title: target_title)
      movie.update_from_omdb
      movie
    end

    def update_from_omdb
      movie_scrapper = Elcinema::Scrapper::Movie.new(title: title)
      omdb_data = movie_scrapper.omdb
      @title    = title
      @year     = omdb_data['Year']
      @runtime  = omdb_data['Runtime']
      @genre    = omdb_data['Genre'].split(', ')
      @actors   = omdb_data['Actors'].split(', ')
      @director = omdb_data['Director']
      @plot     = omdb_data['Plot']
      @awards   = omdb_data['Awards'].split(', ')
    rescue
      @invalid = true
    end
  end
end
