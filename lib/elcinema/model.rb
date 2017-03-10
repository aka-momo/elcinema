module Elcinema
  class Model
    include CachedAttr

    ## Methods
    def initialize(attrs = {})
      assign_attributes(attrs)
    end

    def assign_attributes(attrs = {})
      attrs.each { |key, value| send("#{key}=", value) }
    end
  end
end
