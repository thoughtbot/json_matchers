require "minitest/autorun"
require "json_matchers/minitest/assertions"

JsonMatchers.schema_root = "/test/support/api/schemas"

Minitest::Test.include(JsonMatchers::Minitest::Assertions)

Dir["./test/support/**/*.rb"].each { |file| require file }
