require "fileutils"
require "json"

module FileHelpers
  FakeResponse = Struct.new(:body)

  def create_schema(name, json)
    path = File.join(JsonMatchers.schema_root, "#{name}.json")

    File.open(path, "w") do |file|
      case json
      when NilClass, String
        file.write(json.to_s)
      else
        file.write(JSON.generate(json))
      end
    end
  end

  def response_for(json)
    response_body = case json
                    when String, NilClass
                      json.to_s
                    else
                      json.to_json
                    end
    FakeResponse.new(response_body)
  end

  def setup_fixtures(*pathnames)
    JSON::Validator.clear_cache
    original_schema_root = JsonMatchers.schema_root

    JsonMatchers.schema_root = File.join(*pathnames)
    FileUtils.mkdir_p(JsonMatchers.schema_root)

    original_schema_root
  end

  def teardown_fixtures(original_schema_root)
    FileUtils.rm_rf(JsonMatchers.schema_root)
    JsonMatchers.schema_root = original_schema_root
  end

  def ensure_fixtures(*pathnames)
    original_schema_root = setup_fixtures(*pathnames)

    yield

    teardown_fixtures(original_schema_root)
  end
end
