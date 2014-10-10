require "shoulda/matchers/json/version"
require "json-schema"

module Shoulda
  module Matchers
    module Json
      class InvalidError < StandardError
      end
      class DoesNotMatch < InvalidError
      end

      @@schema_root = "#{Dir.pwd}/spec/support/api/schemas"

      def self.schema_root=(root)
        @@schema_root = root.to_s
      end

      def self.schema_root
        @@schema_root.to_s
      end

      Matcher = Struct.new(:schema_path) do
        def matches?(response)
          JSON::Validator.validate!(schema_path, response.body, strict: true)
        rescue JSON::Schema::ValidationError
          raise DoesNotMatch
        rescue JSON::ParserError
          raise InvalidError
        end
      end

      def match_response_schema(schema_name)
        Matcher.new("#{schema_root}/#{schema_name}.json")
      end
    end
  end
end
