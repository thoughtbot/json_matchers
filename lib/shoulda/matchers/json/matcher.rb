require "json-schema"

module Shoulda
  module Matchers
    module Json
      Matcher = Struct.new(:schema_path) do
        def matches?(response)
          JSON::Validator.validate!(schema_path, response.body, strict: true)
        rescue JSON::Schema::ValidationError
          raise DoesNotMatch
        rescue JSON::ParserError
          raise InvalidError
        end
      end
    end
  end
end
