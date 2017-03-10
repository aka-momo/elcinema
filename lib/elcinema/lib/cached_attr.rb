module Elcinema
  module CachedAttr
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def cached_attr(*attrs, using:)
        return unless attrs.any?

        attr_writer(*attrs)

        @cached_attr_using = case using
                             when Symbol, String
                               ->(*args) { send using, *args }
                             when Proc
                               using
                             end

        attrs.each do |attr|
          class_eval <<~RB, __FILE__, __LINE__ + 1
            def #{attr}
              return @#{attr} if instance_variable_defined?(:@#{attr})

              using = self.class.instance_variable_get(:@cached_attr_using)
              @#{attr} = instance_exec(:#{attr}, &using)
            end
          RB
        end
      end
    end
  end
end
