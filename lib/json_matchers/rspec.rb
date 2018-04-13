require "json_matchers"
require "json_matchers/assertion"

module JsonMatchers
  self.schema_root = File.join("spec", "support", "api", "schemas")
end

RSpec::Matchers.define :match_json_schema do |schema_name, **options|
  if options.present?
    warn <<-WARN
DEPRECATION:

  After `json_matchers@0.9.x`, calls to `match_json_schema` and
  `match_response_schema` will no longer accept options.

  See https://github.com/thoughtbot/json_matchers/pull/31 for more information.

WARN
  end

  assertion = JsonMatchers::Assertion.new(schema_name.to_s, options)

  match do |json|
    assertion.valid?(json)
  end

  if respond_to?(:failure_message)
    failure_message do
      assertion.valid_failure_message
    end

    failure_message_when_negated do
      assertion.invalid_failure_message
    end
  else
    failure_message_for_should do
      assertion.valid_failure_message
    end

    failure_message_for_should_not do
      assertion.invalid_failure_message
    end
  end
end

RSpec::Matchers.alias_matcher :match_response_schema, :match_json_schema
