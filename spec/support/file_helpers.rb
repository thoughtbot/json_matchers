module FileHelpers
  ORIGINAL_SCHEMA_ROOT = JSON::Matchers.schema_root

  def create_schema(name, json)
    File.open("#{schema_root}/#{name}.json", "w") do |file|
      case json
      when NilClass, String
        file.write(json.to_s)
      else
        file.write(json.to_json)
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
    double(body: response_body)
  end

  def schema_root
    JSON::Matchers.schema_root
  end
end

RSpec.configure do |config|
  config.include FileHelpers

  config.around do |example|
    JSON::Matchers.schema_root = File.join(Dir.pwd, "spec", "fixtures", "schemas")
    FileUtils.mkdir_p(JSON::Matchers.schema_root)

    example.run

    FileUtils.rm_rf(JSON::Matchers.schema_root)
    JSON::Matchers.schema_root = FileHelpers::ORIGINAL_SCHEMA_ROOT
  end
end
