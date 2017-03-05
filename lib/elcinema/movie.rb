module Elcinema
  class Movie < Elcinema::Model
    ## Attributes
    attr_accessor :image_url, :title, :actors, :plot, :times
  end
end
