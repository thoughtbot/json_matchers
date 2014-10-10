module Shoulda
  module Matchers
    module Json
      InvalidError = Class.new(StandardError)
      DoesNotMatch = Class.new(InvalidError)
      MissingSchema = Class.new(Errno::ENOENT)
    end
  end
end
