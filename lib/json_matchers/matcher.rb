require "json-schema"
require "json_matchers/payload"

module JsonMatchers
  class Matcher
    def initialize(schema_path, options = {})
      @schema_path = schema_path
      @options = default_options.merge(options)
    end

    def matches?(response)
      # validate! will not raise and will always return true if you configure
      # the validator to record errors, so we must instead inspect
      # fully_validate's errors response
      if options[:record_errors]
        errors = JSON::Validator.fully_validate(
          schema_path.to_s,
          Payload.new(response).to_s,
          options,
        )

        # errors is an array, but it will always only return a single item
        if errors.any?
          @validation_failure_message = errors.first
          false
        else
          true
        end
      else
        JSON::Validator.validate!(
          schema_path.to_s,
          Payload.new(response).to_s,
          options,
        )
      end
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

    def default_options
      JsonMatchers.configuration.options || {}
    end
  end
end
