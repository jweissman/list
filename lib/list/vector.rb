# a vector validates length as well as type

module List
  module Vector
    class LengthRestrictedCollection
      extend List::Types

      attr_reader :values
      def initialize(*values)
        puts "====> CREATE VECTOR (LEN #{self.class.len}) of #{self.class.type}"
        self.class.verify!(values)
        @values = values
        # define ordinal methods?
      end

      def first;  @values[0] end
      def second; @values[1] end
      def third;  @values[2] end
      def fourth; @values[3] end
      def fifth;  @values[4] end

      class << self
        attr_accessor :type, :len
        alias_method :[], :new

        def verify_length(values)
          values.length == self.len
        end

        def detect_invalid(values)
          values.detect do |value|
            !validate_type(object: value, klass: type || superclass.type)
          end
        end

        def verify_types(values)
          !detect_invalid(values)
        end

        def verify(values)
          verify_length(values) && verify_types(values)
        end

        def verify!(values)
          unless verify(values)
            messages = []
            wrong_len = !verify_length(values)
            wrong_type = detect_invalid(values)

            if wrong_len
              message = "#{self} is length-restricted to #{len} elements, but was given #{values.length}"
              puts "WARNING: Vector length incorrect -- #{message}"
              messages.push(message)
            end

            if wrong_type
              message = "#{self} is type-restricted to #{type}, but was given a value #{wrong_type}"
              puts "WARNING: Invalid vector value -- #{message}"
              messages.push(message)
            end

            if List::Configuration.validating?
              raise InvalidVectorStructureError.new(messages.join("; "))
            end
          end
        end

        # def zero_indexed_ordinal_map
        #   { first: 0, second: 1, third: 2 }.update { |v| v - 1 } #.freeze
        # end
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

  class InvalidVectorStructureError < StandardError; end
end

# a pair is a vector of len-2
# Pair = Vector.method(:of).curry(2)
