require "pathname"
require "json_matchers/version"
require "json_matchers/matcher"
require "json_matchers/errors"

module JsonMatchers
  class << self
    attr_accessor :schema_root
  end

  def self.path_to_schema(schema_name)
    Pathname.new(schema_root).join("#{schema_name}.json")
  end
end
