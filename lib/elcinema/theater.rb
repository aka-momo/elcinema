module Elcinema
  class Theater < Elcinema::Model
    ## Attributes
    attr_accessor :id
    cached_attr   :name, :image_url, :address,
                  :movies,
                  using: :fetch

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
      assign_attributes(attrs)[attr]
    end
  end
end
