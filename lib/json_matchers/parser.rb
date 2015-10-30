module JsonMatchers
  class Parser
    def initialize(schema_path)
      @schema_path = schema_path
    end

    def parse
      JsonSchema.parse!(schema_data)
    rescue JSON::ParserError, JsonSchema::SchemaError => error
      raise InvalidSchemaError.new(error)
    end

    private

    attr_reader :schema_path

    def schema_data
      JSON.parse(schema_path.read)
    end
  end
end
