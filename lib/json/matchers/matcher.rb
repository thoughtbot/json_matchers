require "json-schema"

module JSON
  module Matchers
    Matcher = Struct.new(:schema_path) do
      def matches?(response)
        JSON::Validator.validate!(schema_path.to_s, response.body, strict: true)
      rescue JSON::Schema::ValidationError
        false
      rescue JSON::ParserError
        raise InvalidError
      end
    end
  end
end
