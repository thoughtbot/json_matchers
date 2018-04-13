require "json-schema"
require "json_matchers/validator"

module JsonMatchers
  class Matcher
    def initialize(schema_path)
      @schema_path = schema_path
    end

    def matches?(payload)
      validator = build_validator(payload)

      self.errors = validator.validate!

      errors.empty?
    rescue JSON::Schema::ValidationError => error
      self.errors = [error.message]
      false
    rescue JSON::Schema::JsonParseError
      raise InvalidSchemaError
    end

    def validation_failure_message
      errors.first.to_s
    end

    private

    attr_reader :schema_path
    attr_accessor :errors

    def build_validator(payload)
      Validator.new(
        payload: payload,
        schema_path: schema_path,
      )
    end
  end
end
