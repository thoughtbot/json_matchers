module JsonMatchers
  InvalidSchemaError = Class.new(StandardError)
  MissingSchema = Class.new(Errno::ENOENT)
end
