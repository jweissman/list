require 'list/version'
require 'list/tuple'
require 'forwardable'

module List
  class InvalidItemClassError < StandardError; end

  class Collection
    include Enumerable
    extend Forwardable
    attr_reader :elems
    def_delegators :elems, :each
    alias_method :to_a, :elems

    def initialize(elems=[])
      puts "====> CREATE NEW LIST OF #{self.class.type}"
      @elems = elems
    end

    def push(item)
      verify!(item)
      elems << item
    end
    alias_method :<<, :push

  protected
    def verify(it)
      # my_type = self.class.type
      it.is_a?(my_type)
    end

    def verify!(it)
      # my_type = self.class.type
      puts "CHECK: is #{it} a #{my_type}"
      unless verify(it)
        puts "WARNING: #{it} is not #{my_type}"
        if List.validating?
          raise InvalidItemClassError.new("#{it} is not #{my_type}")
        end
      end
    end

    def my_type
      self.class.type || self.class.superclass.type #.pry
    end

    class << self
      attr_accessor :type
    end
  end

  class << self
    def of(klass)
      collection_class = Class.new(Collection)
      collection_class.type = klass
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
