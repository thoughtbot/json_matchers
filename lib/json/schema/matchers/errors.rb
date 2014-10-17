module JSON
  class Schema
    module Matchers
      InvalidError = Class.new(StandardError)
      DoesNotMatch = Class.new(InvalidError)
      MissingSchema = Class.new(Errno::ENOENT)
    end
  end
end
