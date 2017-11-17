# a vector validates length as well as type

module List
  module Vector
    class LengthRestrictedCollection
      attr_reader :values
      def initialize(*values)
        puts "====> CREATE VECTOR (LEN #{self.class.len}) of #{self.class.type}"
        unless values.length == self.class.len
          raise InvalidVectorLengthError.new(
            "Vector #{self.class} is length-restricted to #{self.class.len} elements, but was given #{values.length}"
          )
        end

        @values = values #.freeze
        # define ordinal methods?
      end

      def first
        @values[0]
      end

      def second
        @values[1]
      end

      class << self
        attr_accessor :type, :len
        alias_method :[], :new
      end
    end

    class << self
      def of(len, klass)
        collection_class = Class.new(LengthRestrictedCollection)
        collection_class.type = klass
        collection_class.len = len
        collection_class
      end

      alias_method :[], :of
    end
  end

  class InvalidVectorLengthError < StandardError; end
end

# a pair is a vector of len-2
# Pair = Vector.method(:of).curry(2)
