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

      traverse_schema_root_with_first_level_symlinks.
        map { |path| Pathname.new(path) }.
        map { |schema_path| Parser.new(schema_path).parse }.
        map { |schema| document_store.add_schema(schema) }.
        each { |schema| schema.expand_references!(store: document_store) }

      document_store
    end

    def traverse_schema_root_with_first_level_symlinks
      # follow one symlink and direct children
      # http://stackoverflow.com/questions/357754/can-i-traverse-symlinked-directories-in-ruby-with-a-glob
      Dir.glob("#{JsonMatchers.schema_root}/**{,/*/**}/*.json")
    end
  end
end
