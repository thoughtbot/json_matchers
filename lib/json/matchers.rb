require "json/matchers/version"
require "json/matchers/matcher"
require "json/matchers/errors"
require "active_support/all"

module JSON
  module Matchers
    mattr_accessor :schema_root

    self.schema_root = "#{Dir.pwd}/spec/support/api/schemas"

    def self.path_to_schema(schema_name)
      Pathname(schema_root).join("#{schema_name}.json")
    end
  end
end

if defined?(RSpec)
  require "json/matchers/rspec"
end
