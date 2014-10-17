if RSpec.respond_to?(:configure)
  RSpec::Matchers.define :match_response_schema do |schema_name|
    match do |response|
      schema_path = JSON::Matchers.path_to_schema(schema_name)
      matcher = JSON::Matchers::Matcher.new(schema_path)

      matcher.matches?(response)
    end
  end
end
