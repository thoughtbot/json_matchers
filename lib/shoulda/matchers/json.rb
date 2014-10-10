require "shoulda/matchers/json/version"
require "shoulda/matchers/json/matcher"
require "shoulda/matchers/json/schema_parser"
require "shoulda/matchers/json/errors"
require "active_support/all"

module Shoulda
  module Matchers
    module Json
      mattr_accessor :schema_root

      self.schema_root = "#{Dir.pwd}/spec/support/api/schemas"

      def match_response_schema(schema_name)
        schema_parser = SchemaParser.new(schema_root)

        Matcher.new(schema_parser.schema_for(schema_name))
      end
    end
  end
end

if defined?(RSpec)
  require "shoulda/matchers/json/rspec"
end
