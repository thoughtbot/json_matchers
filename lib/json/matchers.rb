require "json/matchers/version"
require "json/matchers/matcher"
require "json/matchers/schema_parser"
require "json/matchers/errors"
require "active_support/all"

module JSON
  module Matchers
    mattr_accessor :schema_root

    self.schema_root = "#{Dir.pwd}/spec/support/api/schemas"

    def match_response_schema(schema_name)
      schema_parser = SchemaParser.new(schema_root)

      Matcher.new(schema_parser.schema_for(schema_name))
    end
    alias match_json_schema match_response_schema
  end
end

if defined?(RSpec)
  require "json/matchers/rspec"
end
