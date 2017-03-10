module Elcinema
  class Movie < Model
    ## Attributes
    attr_accessor :id, :theater_id
    cached_attr   :title, :year,
                  :trailer_url,
                  :actors, :awards, :directors, :genres, :plot, :poster_url, :rating, :runtime,
                  :times,
                  :theaters,
                  using: :fetch

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
        attrs = Scrapper::Movie.find(id, with_omdb: true, with_trailer: true)
        assign_attributes(attrs)[attr]
      end
    end
  end
end
