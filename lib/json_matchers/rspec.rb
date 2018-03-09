require "delegate"
require "json_matchers"
require "json_matchers/payload"

module JsonMatchers
  class RSpec < SimpleDelegator
    attr_reader :schema_name

    def initialize(schema_name, **options)
      @schema_name = schema_name

      super(JsonMatchers::Matcher.new(schema_path, options))
    end

    def failure_message(json)
      <<-FAIL
#{validation_failure_message}

---

expected

#{pretty_json(json)}

to match schema "#{schema_name}":

#{pretty_json(schema_body)}

      FAIL
    end

    def failure_message_when_negated(json)
      <<-FAIL
#{validation_failure_message}

---

expected

#{pretty_json(json)}

not to match schema "#{schema_name}":

#{pretty_json(schema_body)}

      FAIL
    end

    private

    def pretty_json(json)
      payload = Payload.new(json).to_s

      JSON.pretty_generate(JSON.parse(payload))
    end

    def schema_path
      JsonMatchers.path_to_schema(schema_name)
    end

    def schema_body
      File.read(schema_path)
    end
  end
end

if RSpec.respond_to?(:configure)
  RSpec::Matchers.define :match_json_schema do |schema_name, **options|
    matcher = JsonMatchers::RSpec.new(schema_name, options)

    match do |json|
      matcher.matches?(json)
    end

    if respond_to?(:failure_message)
      failure_message do |json|
        matcher.failure_message(json)
      end

      failure_message_when_negated do |json|
        matcher.failure_message_when_negated(json)
      end
    else
      failure_message_for_should do |json|
        matcher.failure_message(json)
      end

      failure_message_for_should_not do |json|
        matcher.failure_message_when_negated(json)
      end
    end
  end
  RSpec::Matchers.alias_matcher :match_response_schema, :match_json_schema
end
