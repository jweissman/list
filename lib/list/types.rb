module List
  # centralize all type-related logic here?
  module Types
    def validate_type(object:, klass:)
      # check our own internal 'control' classes
      if (klass < List::RespondsTo::Ducktyped) || (klass < List::OneOf::Union)
        # handle ducktyped check / unions
        klass.valid?(object)
      else # normal validation check...
        object.is_a?(klass)
      end
    end
  end
end
