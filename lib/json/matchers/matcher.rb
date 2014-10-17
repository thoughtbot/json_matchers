require "json-schema"

module JSON
  module Matchers
    Matcher = Struct.new(:schema_path) do
      def matches?(response)
        @response = response

        JSON::Validator.validate!(schema_path.to_s, response.body, strict: true)
      rescue JSON::Schema::ValidationError
        false
      rescue JSON::ParserError
        raise InvalidSchemaError
      end
    end
  end
end
