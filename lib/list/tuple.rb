# really wanted to pair types...
module List
  module Tuple
    # class InvalidValueClassError < StandardError; end
    class AbstractTuple
      include List::Types

      attr_reader :values
      def initialize(*args)
        verify!(args)
        @values = args
      end

      def first
        @values[0]
      end

      def second
        @values[1]
      end

      def my_types
        self.class.types || self.class.superclass.types
      end

      def ==(other)
        @values == other.values
      end

      protected
      def detect_invalid(args)
        args.zip(my_types).detect do |it, klass|
          !validate_type(object: it, klass: klass)
        end
      end

      def detect_incomplete(args)
        args.length != my_types.length
      end

      def valid?(args)
        !detect_invalid(args) && !detect_incomplete(args)
      end

      def verify!(args)
        unless valid?(args)
          messages = []
          invalid = detect_invalid(args)
          incomplete = detect_incomplete(args)

          if invalid
            obj, klass = *invalid #detect_invalid(args) #@error #errors(args)
            message = "Invalid tuple structure: #{obj} is not an #{klass}"
            puts "WARNING: #{message}"
            messages.push(message)
          end

          if incomplete
            message = "Tuple #{args} is not complete (length #{args.length} but requires #{my_types.length} elements)"
            puts "WARNING: #{message}"
            messages.push(message)
          end

          if List::Configuration.validating?
            raise InvalidTupleStructureError.new(messages.join("; ")) #"Invalid tuple structure: #{obj} is not a #{klass}")
          end
        end
      end

      class << self
        attr_accessor :types
        alias_method :[], :new
      end
    end

    class << self
      def of(*klasses)
        collection_class = Class.new(AbstractTuple)
        collection_class.types = klasses
        collection_class
      end
      alias_method :apply, :of
      alias_method :[], :of
    end
  end

  class InvalidTupleStructureError < StandardError; end
end
