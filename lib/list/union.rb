module List
  module OneOf
    class Union
      attr_reader :item

      def initialize(it)
        verify!(it)
        @item = it
      end

    protected
      def verify!(obj)
        unless verify(obj)
          raise InvalidDiscriminatedUnionError.new("WARNING: #{obj} is not in the set of types in this union: #{my_types}")
        end
      end

      def verify(obj)
        my_types.detect do |klass|
          obj.is_a?(klass)
        end
      end

      def my_types
        self.class.types || self.class.superclass.types
      end

      class << self
        attr_accessor :types
        alias_method :[], :new
      end
    end

    class << self
      def these(*classes)
        union_class = Class.new(Union)
        union_class.types = classes
        union_class
      end
      alias_method :[], :these
    end


    class InvalidDiscriminatedUnionError < StandardError; end
  end
end
