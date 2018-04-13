require "json-schema"

module JsonMatchers
  class Validator
    def initialize(payload:, schema_path:)
      @payload = payload
      @schema_path = schema_path.to_s
    end

    def validate!
      JSON::Validator.fully_validate(schema_path, payload, record_errors: true)
    end

    private

    attr_reader :payload, :schema_path
  end
end
