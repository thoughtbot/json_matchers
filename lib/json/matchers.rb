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
      Matcher.new(schema_path.join("#{schema_name}.json"))
    end
    alias match_json_schema match_response_schema

    private

    def schema_path
      Pathname(schema_root)
    end
  end
end

if defined?(RSpec)
  require "json/matchers/rspec"
end
