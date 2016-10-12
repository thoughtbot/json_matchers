require "json-schema"

module JsonMatchers
  class Matcher
    def initialize(schema_path, **options)
      @schema_path = schema_path
      @options = options
    end

    def matches?(response)
      JSON::Validator.validate!(
        schema_path.to_s,
        json_from(response).to_s,
        options,
      )
    rescue JSON::Schema::ValidationError => ex
      @validation_failure_message = ex.message
      false
    rescue JSON::Schema::JsonParseError
      raise InvalidSchemaError
    end

    def validation_failure_message
      @validation_failure_message.to_s
    end

    private

    attr_reader :schema_path, :options

    def json_from(response)
      if response.respond_to?(:body)
        response.body
      else
        response
      end
    end
  end
end
