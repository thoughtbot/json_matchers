require "json-schema"

module JSON
  module Matchers
    class Matcher
      def initialize(schema_path, **options)
        @schema_path = schema_path
        @options = options
      end

      def matches?(response)
        @response = response

        validator_options = {
          strict: true,
        }.merge(options)

        JSON::Validator.validate!(
          schema_path.to_s,
          response.body,
          validator_options,
        )
      rescue JSON::Schema::ValidationError => ex
        @validation_failure_message = ex.message
        false
      rescue JSON::ParserError
        raise InvalidSchemaError
      end

      def validation_failure_message
        @validation_failure_message.to_s
      end

      private

      attr_reader :schema_path, :options
    end
  end
end
