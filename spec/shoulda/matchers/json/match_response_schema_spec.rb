require "active_support/all"
require "shoulda/matchers/json"

describe Shoulda::Matchers::Json, "#match_response_schema" do
  it "fails with an invalid JSON body" do
    create_schema("foo", nil)
    response = double(body: "")

    expect {
      expect(response).to match_response_schema("foo")
    }.to raise_error(Shoulda::Matchers::Json::InvalidError)
  end

  it "does not fail with an empty JSON body" do
    create_schema("foo", {})
    response = double(body: "{}")

    expect(response).to match_response_schema("foo")
  end

  it "fails when the body is missing a required property" do
    create_schema("array_schema", {
      type: "object",
      required: ["foo"],
    })
    without_required = double(body: {})

    expect {
      expect(without_required).to match_response_schema("array_schema")
    }.to raise_error(Shoulda::Matchers::Json::DoesNotMatch)
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("array_schema", {
      type: "object",
      properties: {
        foo: { type: "string" }
      }
    })
    wrong_type = double(body: { foo: 1 })

    expect {
      expect(wrong_type).to match_response_schema("array_schema")
    }.to raise_error(Shoulda::Matchers::Json::DoesNotMatch)
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      type: "array",
      items: { type: "string" }
    })
    response = double(body: ["valid"])

    expect(response).to match_response_schema("array_schema")
  end

  def create_schema(name, json_as_hash)
    File.open("#{schema_root}/#{name}.json", "w") do |file|
      file.write(json_as_hash.to_json)
    end
  end

  def schema_root
    Shoulda::Matchers::Json.schema_root
  end

  around do |example|
    original_schema_root = Shoulda::Matchers::Json.schema_root
    Shoulda::Matchers::Json.schema_root = "spec/support/fixture_schemas"
    FileUtils.mkdir_p(Shoulda::Matchers::Json.schema_root)

    example.run

    FileUtils.rm_rf(Shoulda::Matchers::Json.schema_root)
    Shoulda::Matchers::Json.schema_root = original_schema_root
  end
end
