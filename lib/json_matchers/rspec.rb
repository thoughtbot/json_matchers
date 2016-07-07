require "delegate"
require "json_matchers"

module JsonMatchers
  class RSpec < SimpleDelegator
    attr_reader :schema_name

    def initialize(schema_name, **options)
      @schema_name = schema_name

      super(JsonMatchers::Matcher.new(schema_path, options))
    end

    def failure_message(response)
      strip_heredoc(<<-FAIL)
      expected

      #{response.body}

      to match schema "#{schema_name}":

      #{schema_body}

      ---

      #{validation_failure_message}

      FAIL
    end

    def failure_message_when_negated(response)
      strip_heredoc(<<-FAIL)
      expected

      #{response.body}

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

    private

    def strip_heredoc(str)
      indent = str.scan(/^[ \t]*(?=\S)/).min
      indent = indent ? indent.size : 0
      str.gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end

if RSpec.respond_to?(:configure)
  RSpec::Matchers.define :match_response_schema do |schema_name, **options|
    matcher = JsonMatchers::RSpec.new(schema_name, options)

    match do |response|
      matcher.matches?(response)
    end

    if respond_to?(:failure_message)
      failure_message do |response|
        matcher.failure_message(response)
      end

      failure_message_when_negated do |response|
        matcher.failure_message_when_negated(response)
      end
    else
      failure_message_for_should do |response|
        matcher.failure_message(response)
      end

      failure_message_for_should_not do |response|
        matcher.failure_message_when_negated(response)
      end
    end
  end
end
