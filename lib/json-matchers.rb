warn <<-WARNING
DEPRECATED: requiring the library via `require "json-matchers"` is deprecated.

To include the library, please add `require "json_matchers/rspec"` to your
`spec/spec_helper.rb`.
WARNING

require "json_matchers"

if defined?(RSpec)
  require "json_matchers/rspec"
end
