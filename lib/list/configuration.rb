module List
  module Configuration
    class << self
      def validating?
        @validating ||= false # could set true in test runs?
      end

      def validate!
        @validating = true
      end
    end
  end
end
