# really wanted to pair types...
module Tuple
  class InvalidValueClassError < StandardError; end
  class AbstractTuple
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
    def valid?(args)
      @error ||= args.zip(my_types).detect do |it,type|
        !it.is_a?(type)
      end
      @error.nil?
    end
    # alias_method :errors, :valid?

    def verify!(args)
      unless valid?(args)
        obj, klass = *@error #errors(args)
        print "WARNING: Invalid tuple structure: #{obj} is not a #{klass}"
        if List.validating?
          raise InvalidValueClassError.new("Invalid tuple structure: #{obj} is not a #{klass}")
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
