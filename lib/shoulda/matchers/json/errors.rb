module Shoulda
  module Matchers
    module Json
      InvalidError = Class.new(StandardError)
      DoesNotMatch = Class.new(InvalidError)
    end
  end
end
