module List
  module Function
    class Mapping
      include List::Types

      def initialize(meth)
        @meth = meth
      end

      def call(*args)
        verify_input(*args)
        result = @meth[*args]
        verify_output(result)
        result
      end
      alias_method :invoke, :call
      alias_method :[], :call
      alias_method :apply, :call

      def verify_input(args)
        unless validate_type(object: args, klass: self.class.input)
          puts "WARNING: Function result #{args} didn't match expected type #{self.class.input}"
          if List::Configuration.validating?
            raise InvalidFunctionArgumentError.new("Function argument #{args} is not #{self.class.input}")
          end
        end
      end

      # it's okay...
      def verify_output(args)
        unless validate_type(object: args, klass: self.class.output)
          puts "WARNING: Function result #{args} didn't match expected type #{self.class.output}"
          if List::Configuration.validating?
            raise InvalidFunctionResultError.new("Function result #{args} were not #{self.class.output}")
          end
        end
      end

      class << self
        attr_accessor :method, :input, :output
      end
    end

    class << self
      def between(input_output)
        inp,out = input_output.first
        function_class = Class.new(Mapping)
        # function_class.method = fn
        function_class.input = inp
        function_class.output = out
        function_class
      end
      alias_method :[], :between
    end
  end

  class InvalidFunctionResultError < StandardError; end
  class InvalidFunctionArgumentError < StandardError; end
end
