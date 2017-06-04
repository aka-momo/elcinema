module Elcinema
  class Movie < Model
    ## Constants
    CACHED_ATTRS = %i(title year
                      trailer_url
                      actors awards directors genres plot poster_url rating runtime
                      times
                      theaters)

    ## Attributes
    attr_accessor :provider, :id, :theater_id
    cached_attr   *CACHED_ATTRS, using: :fetch

    ## Methods
    def self.s(provider)
      eval("Scrapper::#{provider}::Movie")
    end

    def self.all(provider:)
      s(provider).all.map { |attr| new(attr.merge(provider: provider)) }
    end

    def self.find(id, provider:)
      new(provider: provider, id: id)
    end

    def fetch(attr)
      case attr
      when :times
        self.class.s(provider).times_for(id).tap do |times|
          unless theater_id.nil?
            times = times.find { |t| t[:theater_id] == theater_id }
            return times[:times] unless times.nil?
          end
        end
      when :theaters
        return [Theater.new(provider: provider, id: theater_id)] unless theater_id.nil?
        times.map { |time| Theater.new(provider: provider, id: time[:theater_id]) }
      else
        attrs = self.class.s(provider).find(id, with_meta: true, with_trailer: true)
        attrs = CACHED_ATTRS.zip([] * CACHED_ATTRS.size).to_h
                            .reject { |k, _| %i(times theaters).include?(k) }
                            .merge(attrs)
        assign_attributes(attrs)[attr]
      end
    end
  end
end
