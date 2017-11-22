module List
  # centralize all type-related logic here?
  module Types
    def validate_type(object:, klass:)
      puts "==== VALIDATE TYPE object=#{object} klass=#{klass}"
      # check our own internal 'control' classes
      # todo record should verify structure?
      if klass.is_a?(List::Datatype::TypeDatabase::TypePlaceholder)
        resolved = klass.reify # List::Datatype::TypeDatabase.dereference(klass.sym)
        # binding.pry # if object.is_a?(Tree)
        validate_type(object: object, klass: resolved) ||
          validate_type(object: object, klass: resolved.structure) # ??
      elsif (klass < List::RespondsTo::Ducktyped) || (klass < List::OneOf::Union)
        # handle ducktyped check / unions
        klass.valid?(object)
      elsif (klass < List::Collection)
        object.all? { |it| klass.validate_item(it) }
      else # normal validation check...
        object.is_a?(klass)
      end
    end
  end
end
