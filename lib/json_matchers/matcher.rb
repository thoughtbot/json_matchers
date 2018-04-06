require "json-schema"
require "json_matchers/validator"

module JsonMatchers
  class Matcher
    def initialize(schema_path, options = {})
      @schema_path = schema_path
      @options = default_options.merge(options)
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

    attr_reader :schema_path, :options
    attr_accessor :errors

    def default_options
      JsonMatchers.configuration.options || {}
    end

    def build_validator(payload)
      Validator.new(
        options: options,
        payload: payload,
        schema_path: schema_path,
      )
    end
  end
end
