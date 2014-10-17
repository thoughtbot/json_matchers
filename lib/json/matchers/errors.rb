module JSON
  module Matchers
    InvalidSchemaError = Class.new(StandardError)
    MissingSchema = Class.new(Errno::ENOENT)
  end
end
