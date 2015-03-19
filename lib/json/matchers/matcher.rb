require "json-schema"

module JSON
  module Matchers
    Matcher = Struct.new(:schema_path) do
      def matches?(response)
        @response = response

        JSON::Validator.validate!(schema_path.to_s, response.body, strict: true)
      rescue JSON::Schema::ValidationError => ex
        @validation_failure_message = ex.message
        false
      rescue JSON::ParserError
        raise InvalidSchemaError
      end

      def validation_failure_message
        @validation_failure_message.to_s
      end
    end
  end
end
