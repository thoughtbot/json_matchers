require "json_schema"
require "json_matchers/parser"
require "json_matchers/validator"

module JsonMatchers
  class Matcher
    def initialize(schema_path)
      @schema_path = schema_path
      @document_store = build_and_populate_document_store
    end

    def matches?(payload)
      self.errors = validator.validate(payload)

      errors.empty?
    end

    def validation_failure_message
      errors.first.to_s
    end

    private

    attr_accessor :errors
    attr_reader :document_store, :schema_path

    def validator
      Validator.new(schema_path: schema_path, document_store: document_store)
    end

    def build_and_populate_document_store
      document_store = JsonSchema::DocumentStore.new

      Dir.glob("#{JsonMatchers.schema_root}/**/*.json").
        map { |path| Pathname.new(path) }.
        map { |schema_path| Parser.new(schema_path).parse }.
        each { |schema| document_store.add_schema(schema) }

      document_store.to_a.each do |_k, schema|
        schema.expand_references!(store: document_store)
      end

      document_store
    end
  end
end
