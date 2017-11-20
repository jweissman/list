module List
  module Record
    class TypedKeyValues
      include List::Types

      def initialize(**kwargs)
        puts "===> CREATE NEW RECORD OF #{my_structure}"
        verify!(kwargs)
        @data = kwargs
        self.class.build_accessors(@data.keys)
      end

      def my_structure
        self.class.structure || self.class.superclass.structure
      end

    protected
      def valid?(key, value)
        # value.is_a?(my_structure[key])
        validate_type(
          object: value,
          klass: my_structure[key]
        )
      end

      def detect_invalid(kwargs)
        kwargs.detect { |k,v| !valid?(k,v) }
      end

      def detect_incomplete(kwargs)
        my_structure.keys.detect { |key,_| !kwargs.has_key?(key) }
      end

      def verify(kwargs)
        !detect_invalid(kwargs) && !detect_incomplete(kwargs)
      end

      def verify!(kwargs)
        unless verify(kwargs)
          messages = []
          invalid = detect_invalid(kwargs)
          incomplete = detect_incomplete(kwargs)

          if invalid
            key, val = *invalid
            message = "#{val} is not a #{my_structure[key]} (was assigned to #{key}) "
            puts "WARNING: Record invalid -- #{message}"
            messages.push(message)
          end

          if incomplete
            missing_key = incomplete
            message = "Missing key #{missing_key} from record #{my_structure}"
            puts "WARNING: Record incomplete -- #{message}"
            messages.push(message)
          end

          if List::Configuration.validating?
            raise InvalidRecordStructureError.new(messages.join("; "))
          end
        end
      end

      class << self
        attr_accessor :structure

        def build_accessors(keys)
          keys.each do |key|
            build_accessor(key)
          end
        end

        def build_accessor(key)
          define_method(key) { @data[key] }
          define_method(:"#{key}=") do |val|
            if valid?(key,val)
              @data[key] = val
            else
              message = "#{val} is not a #{my_structure[key]} (was assigned to #{key})"
              puts "WARNING: Record assignment invalid -- #{message}"
              if List::Configuration.validating?
                raise InvalidRecordStructureError.new(message)
              end
            end
          end
        end
      end
    end

    class << self
      def of(keys_and_klasses)
        record_class = Class.new(TypedKeyValues)
        record_class.structure = keys_and_klasses
        record_class
      end
      alias_method :[], :of
    end
  end

  class InvalidRecordStructureError < StandardError; end
  # class IncompleteRecordError < StandardError; end
end
