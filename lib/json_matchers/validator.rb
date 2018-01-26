require "json_schema"
require "json_matchers/payload"

module JsonMatchers
  class Validator
    def initialize(options:, response:, schema_path:)
      @options = options.dup
      @payload = Payload.new(response).to_s
      @schema_path = schema_path.to_s

      add_schemata_to_document_store
    end

    def validate!
      schema_data = JSON.parse(File.read(schema_path.to_s))
      json_schema = JsonSchema.parse!(schema_data)

      json_schema.expand_references!(store: document_store)
      json_schema.validate!(payload)

      []
    rescue JsonSchema::SchemaError, JSON::ParserError => error
      [error.message]
    end

    private

    attr_reader :options, :payload, :schema_path

    def add_schemata_to_document_store
      Dir.glob("#{JsonMatchers.schema_root}/**/*.json").each do |path|
        begin
          extra_schema = JsonSchema.parse!(File.read(path))
          document_store.add_schema(extra_schema)
        rescue JsonSchema::AggregateError => error
          raise JsonMatchers::InvalidSchemaError.new(error)
        end
      end
    end

    def document_store
      @document_store ||= JsonSchema::DocumentStore.new
    end

    def recording_errors?
      options.fetch(:record_errors, false)
    end
  end
end
