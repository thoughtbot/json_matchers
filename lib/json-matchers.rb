warn <<-WARNING
DEPRECATED: The `json-matchers` gem has been deprecated.

Please replace change your Gemfile's reference from `json-matchers` to
`json_matchers`.
WARNING

require "json_matchers"

if defined?(RSpec)
  require "json_matchers/rspec"
end
