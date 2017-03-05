module Elcinema
  class Theater < Elcinema::Model
    ## Attributes
    attr_accessor :name, :location, :image_url, :movies

    ## Methods
    def self.find(id)
      scrapper = Elcinema::Scrapper::Theater.new(id: id)
      scrapper.execute
    rescue => _
      nil
    end

    def self.find_from_omdb(id)
      theater = find(id)
      theater.movies.each(&:update_from_omdb)
      theater.movies.reject(&:invalid)
    rescue
      nil
    end
  end
end
