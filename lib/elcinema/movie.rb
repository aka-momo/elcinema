module Elcinema
  class Movie < Model
    ## Constants
    CACHED_ATTRS = %i(title year
                      trailer_url
                      actors awards directors genres plot poster_url rating runtime
                      times
                      theaters)

    ## Attributes
    attr_accessor :id, :theater_id
    cached_attr   *CACHED_ATTRS, using: :fetch

    ## Methods
    def self.all
      Scrapper::Movie.all.map(&method(:new))
    end

    def self.find(id)
      new(id: id)
    end

    def fetch(attr)
      case attr
      when :times
        Scrapper::Movie.times_for(id).tap do |times|
          unless theater_id.nil?
            times = times.find { |t| t[:theater_id] == theater_id }
            return times[:times] unless times.nil?
          end
        end
      when :theaters
        return [Theater.new(id: theater_id)] unless theater_id.nil?
        times.map { |time| Theater.new(id: time[:theater_id]) }
      else
        attrs = Scrapper::Movie.find(id, with_meta: true, with_trailer: true)
        attrs = CACHED_ATTRS.zip([] * CACHED_ATTRS.size).to_h
                            .reject { |k, _| %i(times theaters).include?(k) }
                            .merge(attrs)
        assign_attributes(attrs)[attr]
      end
    end
  end
end
