require "json"
require "json_matchers"
require "json_matchers/payload"
require "json_matchers/matcher"

module JsonMatchers
  class Assertion
    def initialize(schema_name, **options)
      @schema_name = schema_name
      @schema_path = JsonMatchers.path_to_schema(schema_name)
      @matcher = Matcher.new(schema_path, options)
    end

    def valid?(json)
      @payload = Payload.new(json)

      matcher.matches?(payload.to_s)
    end

    def valid_failure_message
      <<-FAIL
#{last_error_message}

---

expected

#{format_json(payload)}

to match schema "#{schema_name}":

#{format_json(schema_body)}
      FAIL
    end

    def invalid_failure_message
      <<-FAIL
#{last_error_message}

---

expected

#{format_json(payload)}

not to match schema "#{schema_name}":

#{format_json(schema_body)}
      FAIL
    end

    private

    attr_reader :payload, :matcher, :schema_name, :schema_path

    def last_error_message
      matcher.validation_failure_message
    end

    def schema_body
      File.read(schema_path)
    end

    def format_json(json)
      JSON.pretty_generate(JSON.parse(json.to_s))
    end
  end
end
