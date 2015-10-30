require "json_matchers/parser"

module JsonMatchers
  class Validator
    def initialize(document_store:, schema_path:)
      @document_store = document_store
      @schema_path = schema_path
    end

    def validate(payload)
      json_schema.validate!(payload.as_json, fail_fast: true)

      []
    rescue JsonSchema::Error => error
      [error.message]
    end

    private

    attr_reader :document_store, :schema_path

    def json_schema
      @json_schema ||= build_json_schema_with_expanded_references
    end

    def build_json_schema_with_expanded_references
      json_schema = Parser.new(schema_path).parse

      json_schema.expand_references!(store: document_store)

      json_schema
    end
  end
end
