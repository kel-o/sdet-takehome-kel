module Api
  module ErrorService
    class ApiError < StandardError
      attr_reader :code, :message

      def initialize(code, message)
        @code = code
        @message = message
      end
    end
  end
end
