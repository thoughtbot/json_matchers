module JSON
  module Matchers
    class RSpec < SimpleDelegator
      attr_reader :schema_name

      def initialize(schema_name)
        @schema_name = schema_name

        super(JSON::Matchers::Matcher.new(schema_path))
      end

      def failure_message(response)
        <<-FAIL.strip_heredoc
        expected

        #{response.body}

        to match schema "#{schema_name}":

        #{schema_body}
        FAIL
      end

      def failure_message_when_negated(response)
        <<-FAIL.strip_heredoc
        expected

        #{response.body}

        not to match schema "#{schema_name}":

        #{schema_body}
        FAIL
      end

      def schema_path
        JSON::Matchers.path_to_schema(schema_name)
      end

      def schema_body
        File.read(schema_path)
      end
    end
  end
end

if RSpec.respond_to?(:configure)
  RSpec::Matchers.define :match_response_schema do |schema_name|
    matcher = JSON::Matchers::RSpec.new(schema_name)

    match do |response|
      matcher.matches?(response)
    end

    failure_message do |response|
      matcher.failure_message(response)
    end

    failure_message_when_negated do |response|
      matcher.failure_message_when_negated(response)
    end
  end
end
