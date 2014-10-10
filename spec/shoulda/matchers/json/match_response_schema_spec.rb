require "shoulda/matchers/json"

describe Shoulda::Matchers::Json, "#match_response_schema" do
  it "fails when the schema is missing" do
    expect {
      expect(response_for("")).to match_response_schema("missing")
    }.to raise_error(Shoulda::Matchers::Json::MissingSchema, /missing.json/)
  end

  it "fails with an invalid JSON body" do
    create_schema("foo", "")

    expect {
      expect(response_for("")).to match_response_schema("foo")
    }.to raise_error(Shoulda::Matchers::Json::InvalidError)
  end

  it "does not fail with an empty JSON body" do
    create_schema("foo", {})

    expect(response_for({})).to match_response_schema("foo")
  end

  it "fails when the body is missing a required property" do
    create_schema("array_schema", {
      type: "object",
      required: ["foo"],
    })

    expect {
      expect(response_for({})).to match_response_schema("array_schema")
    }.to raise_error(Shoulda::Matchers::Json::DoesNotMatch, /{}/)
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("array_schema", {
      type: "object",
      properties: {
        foo: { type: "string" }
      }
    })

    expect {
      expect(response_for({foo: 1})).to match_response_schema("array_schema")
    }.to raise_error(Shoulda::Matchers::Json::DoesNotMatch, /{"foo":1}/)
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      type: "array",
      items: { type: "string" }
    })

    expect(response_for(["valid"])).to match_response_schema("array_schema")
  end

  it "supports ERB" do
    create_schema "array_schema", <<-JSON.strip_heredoc
    {
      "type": "array",
      "items": <%= { type: "string" }.to_json %>
    }
    JSON

    expect(response_for(["valid"])).to match_response_schema("array_schema")
  end
end
