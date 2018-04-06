require "json_matchers"
require "json_matchers/assertion"

module JsonMatchers
  self.schema_root = File.join("test", "support", "api", "schemas")

  module Minitest
    module Assertions
      def assert_matches_json_schema(payload, schema_name)
        assertion = Assertion.new(schema_name)

        payload_is_valid = assertion.valid?(payload)

        assert payload_is_valid, -> { assertion.valid_failure_message }
      end

      def refute_matches_json_schema(payload, schema_name)
        assertion = Assertion.new(schema_name)

        payload_is_valid = assertion.valid?(payload)

        refute payload_is_valid, -> { assertion.invalid_failure_message }
      end
    end
  end
end
