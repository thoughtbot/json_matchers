require "json-schema"

module Shoulda
  module Matchers
    module Json
      Matcher = Struct.new(:schema_path) do
        def matches?(response)
          if file_missing?
            raise MissingSchema, schema_path
          end
          validate!(response)
        end

        private

        def validate!(response)
          JSON::Validator.validate!(json_schema, response.body, strict: true)
        rescue JSON::Schema::ValidationError
          raise DoesNotMatch, response.body
        rescue JSON::ParserError
          raise InvalidError
        end

        def file_missing?
          ! File.exists?(schema_path)
        end

        def json_schema
          JSON.parse(parsed_schema)
        end

        def parsed_schema
          ERB.new(schema_file.read).result()
        end

        def schema_file
          File.new(schema_path)
        end
      end
    end
  end
end
