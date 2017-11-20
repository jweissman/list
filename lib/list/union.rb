module List
  module OneOf
    class Union
      extend List::Types
      attr_reader :item

      def initialize(it)
        verify!(it)
        @item = it
      end

    protected
      def verify!(obj)
        unless verify(obj)
          raise InvalidUnionStructureError.new("WARNING: #{obj} is not in the set of types in this union: #{my_types}")
        end
      end

      def verify(obj)
        self.class.valid?(obj)
      end

      def my_types
        self.class.types || self.class.superclass.types
      end

      class << self
        attr_accessor :types
        alias_method :[], :new

        def inspect
          "OneOf[#{types.join(',')}]"
        end
        alias_method :to_s, :inspect

        def valid?(obj)
          (types || superclass.types).detect do |klass|
            validate_type(object: obj, klass: klass)
          end
        end
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
  end

  class InvalidUnionStructureError < StandardError; end
end
