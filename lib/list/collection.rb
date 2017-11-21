module List
  class Collection
    include Enumerable
    extend Forwardable

    extend List::Types
    attr_reader :elems
    def_delegators :elems, :each
    alias_method :to_a, :elems

    def initialize(*elems) #=[])
      puts "====> CREATE NEW LIST OF #{my_type}"
      elems.map(&method(:verify!))
      @elems = elems
    end

    def push(item)
      verify!(item)
      elems << item
    end
    alias_method :<<, :push

  protected
    def valid?(it)
      self.class.validate_item(it)
      # validate_type(object: it, klass: my_type)
      # it.is_a?(my_type)
    end

    def verify!(it)
      puts "CHECK: is #{it} a #{my_type}"
      unless valid?(it)
        puts "WARNING: #{it} is not #{my_type}"
        if List::Configuration.validating?
          raise InvalidItemClassError.new("#{it} is not #{my_type}")
        end
      end
    end

    def my_type
      self.class.type || self.class.superclass.type
    end

    class << self
      attr_accessor :type
      def validate_item(it)
        validate_type(object: it, klass: type || superclass.type)
      end
    end
  end

  class << self
    def of(klass)
      collection_class = Class.new(Collection)
      collection_class.type = klass
      collection_class
    end
    alias_method :[], :of
  end

  class InvalidItemClassError < StandardError; end
end
