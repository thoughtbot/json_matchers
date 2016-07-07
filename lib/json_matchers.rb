require "json_matchers/version"
require "json_matchers/matcher"
require "json_matchers/errors"
require "active_support/all"

module JsonMatchers
  @@schema_root = "#{Dir.pwd}/spec/support/api/schemas"

  def self.schema_root
    @@schema_root
  end

  def self.schema_root=(value)
    @@schema_root = value
  end

  def self.path_to_schema(schema_name)
    Pathname(schema_root).join("#{schema_name}.json")
  end
end
