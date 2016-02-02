require "json-schema"

module JsonMatchers
  class Matcher
    def self.extract_response_body(response)
      if response.respond_to?(:body)
        response.body
      elsif response.is_a?(String)
        response
      else
        fail "Response does not have a #body method and is " \
             "not a string. It has the class class " \
             "#{response.class}."
      end
    end

    def initialize(schema_path, **options)
      @schema_path = schema_path
      @options = options
    end

    def matches?(response)
      JSON::Validator.validate!(
        schema_path.to_s,
        Matcher.extract_response_body(response),
        options,
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
