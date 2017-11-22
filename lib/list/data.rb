module List
  module Datatype
    module TypeDatabase
      class TypePlaceholder < Struct.new(:sym)
        def reify
          TypeDatabase.dereference(sym)
        end
      end

      def self.reference(sym)
        TypePlaceholder.new(sym)
      end

      def self.dereference(sym)
        @types ||= {}
        @types[sym] # || raise "no such custom type #{sym}"
      end

      def self.define(sym, klass:) # structure:, klass:)
        @types ||= {}
        @types[sym] = klass # structure
      end
    end

    class AbstractType
      include List::Types
      attr_reader :item
      def initialize(obj)
        validate_type(object: obj, klass: self.class.my_structure)
        @item = obj
      end

      class << self
        attr_accessor :sym, :structure
        alias_method :[], :new

        def my_structure
          structure || superclass.structure
          # TypeDatabase.dereference(my_sym)
        end

        def my_sym
          sym || superclass.sym
        end
      end
    end

    class << self
      def define_or_dereference(sym, structure=nil)
        puts "---> define or deref sym"
        if structure.nil?
          # deref...?
          TypeDatabase.reference(sym) # || sym # syms as placeholders?
        else
          # build class?
          abstract_type_class = Class.new(AbstractType) #.new
          abstract_type_class.sym = sym
          abstract_type_class.structure = structure # reify(structure)

          TypeDatabase.define(sym, klass: abstract_type_class)

          abstract_type_class
        end
      end

      # def reify(structure)
      #   case structure
      #   when List::OneOf::Union then
      #     structure.types.map! { |type| reify(type) }
      #     # reify each one?
      #   # when List then # reify types?
      #   else structure
      #   end
      # end

      alias_method :[], :define_or_dereference
    end
  end

  # class InvalidAbstractTypeStructure < StandardError; end
end
