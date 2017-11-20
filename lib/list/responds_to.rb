module List
  module RespondsTo
    # a tiny wrapper around a value
    class Ducktyped
      attr_accessor :item

      def initialize(item)
        if self.class.valid?(item)
          @item = item
        else
          raise InvalidDucktypingError.new("#{item} does not respond to #{self.class.sym}")
        end
      end

      class << self
        attr_accessor :sym
        alias_method :[], :new

        def valid?(obj)
          obj.respond_to?(sym || superclass.sym)
          # (types || superclass.types)
        end

      end
    end

    class << self
      def message(sym)
        ducktyped_class = Class.new(Ducktyped)
        ducktyped_class.sym = sym
        ducktyped_class
      end
      alias_method :[], :message
    end
  end

  # maybe we got smth like BasicObject which doesn't respond to #respond_to :/
  # class InvalietError < StandardError; end
  class InvalidDucktypingError < StandardError; end
  # class InvalidRespondsToTargetError < StandardError; end
end
