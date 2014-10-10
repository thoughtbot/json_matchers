module FileHelpers
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
    Shoulda::Matchers::Json.schema_root
  end
end

RSpec.configure do |config|
  config.include FileHelpers

  config.around do |example|
    original_schema_root = Shoulda::Matchers::Json.schema_root
    Shoulda::Matchers::Json.schema_root = "#{Dir.pwd}/spec/fixtures/schemas"
    FileUtils.mkdir_p(Shoulda::Matchers::Json.schema_root)

    example.run

    FileUtils.rm_rf(Shoulda::Matchers::Json.schema_root)
    Shoulda::Matchers::Json.schema_root = original_schema_root
  end
end
