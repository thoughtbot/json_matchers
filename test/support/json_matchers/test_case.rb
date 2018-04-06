require "active_support/testing/declarative"
require_relative "../../../spec/support/file_helpers"

module JsonMatchers
  class TestCase < ::Minitest::Test
    extend ActiveSupport::Testing::Declarative

    include FileHelpers

    def setup
      @original_schema_root = setup_fixtures("test", "fixtures", "schemas")
    end

    def teardown
      teardown_fixtures(@original_schema_root)
    end
  end
end
