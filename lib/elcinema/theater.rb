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
  end
end
