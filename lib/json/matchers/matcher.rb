require "json-schema"

module JSON
  module Matchers
    Matcher = Struct.new(:schema) do
      def matches?(response)
        JSON::Validator.validate!(json_schema, response.body, strict: true)
      rescue JSON::Schema::ValidationError
        raise DoesNotMatch, response.body
      rescue JSON::ParserError
        raise InvalidError
      end

      private

      def json_schema
        JSON.parse(schema)
      end
    end
  end
end
