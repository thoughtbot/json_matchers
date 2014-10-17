require "json/schema/matchers/version"
require "json/schema/matchers/matcher"
require "json/schema/matchers/schema_parser"
require "json/schema/matchers/errors"
require "active_support/all"

module JSON
  class Schema
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
end

if defined?(RSpec)
  require "json/schema/matchers/rspec"
end
