require "json_matchers"

module JsonMatchers
  class RSpec < SimpleDelegator
    attr_reader :schema_name

    def initialize(schema_name, **options)
      @schema_name = schema_name

      super(JsonMatchers::Matcher.new(schema_path, options))
    end

    def failure_message(response_body)
      <<-FAIL.strip_heredoc
      expected

      #{response_body}

      to match schema "#{schema_name}":

      #{schema_body}

      ---

      #{validation_failure_message}

      FAIL
    end

    def failure_message_when_negated(response_body)
      <<-FAIL.strip_heredoc
      expected

      #{response_body}

      not to match schema "#{schema_name}":

      #{schema_body}

      ---

      #{validation_failure_message}

      FAIL
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
  RSpec::Matchers.define :match_response_schema do |schema_name, **options|
    matcher = JsonMatchers::RSpec.new(schema_name, options)

    match do |response|
      matcher.matches?(response.body)
    end

    if respond_to?(:failure_message)
      failure_message do |response|
        matcher.failure_message(response.body)
      end

      failure_message_when_negated do |response|
        matcher.failure_message_when_negated(response.body)
      end
    else
      failure_message_for_should do |response|
        matcher.failure_message(response.body)
      end

      failure_message_for_should_not do |response|
        matcher.failure_message_when_negated(response.body)
      end
    end
  end

  RSpec::Matchers.define :match_json_schema do |schema_name, **options|
    matcher = JsonMatchers::RSpec.new(schema_name, options)

    match do |json_response|
      matcher.matches?(json_response)
    end

    if respond_to?(:failure_message)
      failure_message do |json_response|
        matcher.failure_message(json_response)
      end

      failure_message_when_negated do |json_response|
        matcher.failure_message_when_negated(json_response)
      end
    else
      failure_message_for_should do |json_response|
        matcher.failure_message(json_response)
      end

      failure_message_for_should_not do |json_response|
        matcher.failure_message_when_negated(json_response)
      end
    end
  end
end
