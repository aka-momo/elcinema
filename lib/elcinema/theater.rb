module Elcinema
  class Theater < Model
    ## Constants
    CACHED_ATTRS = %i(name image_url address
                      movies)

    ## Attributes
    attr_accessor :provider, :id
    cached_attr   *CACHED_ATTRS, using: :fetch

    ## Methods
    def self.s(provider:)
      eval("Scrapper::#{provider}::Theater")
    end

    def self.all(provider:)
      s(provider).all.map { |attr| new(attr.merge(provider: provider)) }
    end

    def self.find(id, provider:)
      new(provider: provider, id: id)
    end

    def fetch(attr)
      attrs = self.class.s(provider: provider).find(id)
      attrs[:movies].map! { |m| Movie.new(m.merge(provider: provider, theater_id: id)) }

      attrs = CACHED_ATTRS.zip([] * CACHED_ATTRS.size).to_h.merge(attrs)
      assign_attributes(attrs)[attr]
    end
  end
end
