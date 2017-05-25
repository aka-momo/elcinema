module Elcinema
  class Theater < Elcinema::Model
    ## Constants
    CACHED_ATTRS = %i(name image_url address
                      movies)

    ## Attributes
    attr_accessor :id
    cached_attr   *CACHED_ATTRS, using: :fetch

    ## Methods
    def self.all
      Scrapper::Theater.all.map(&method(:new))
    end

    def self.find(id)
      new(id: id)
    end

    def fetch(attr)
      attrs = Scrapper::Theater.find(id)
      attrs[:movies].map! { |m| Movie.new(m.merge(theater_id: id)) }

      attrs = CACHED_ATTRS.zip([] * CACHED_ATTRS.size).to_h.merge(attrs)
      assign_attributes(attrs)[attr]
    end
  end
end
