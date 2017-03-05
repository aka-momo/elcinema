module Elcinema
  class Model
    ## Methods
    def initialize(attrs = {})
      attrs.each { |key, value| send("#{key}=", value) }
    end
  end
end
