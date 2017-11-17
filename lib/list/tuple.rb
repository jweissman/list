# really wanted to pair types...
module Tuple
  class TupleSet
    class << self
      attr_accessor :types
    end
  end

  class << self
    def of(*klasses)
      collection_class = Class.new(TupleSet)
      collection_class.types = klasses
      collection_class
    end
    alias_method :apply, :of
    alias_method :[], :of

    def validating?
      @validating ||= false # could set true in test runs?
    end

    def validate!
      @validating = true
    end
  end
end
