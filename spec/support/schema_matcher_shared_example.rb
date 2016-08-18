RSpec.shared_examples 'schema_matcher' do
  it "fails with an invalid JSON body" do
    create_schema("foo", "")

    expect {
      expect(send(file_helper, "")).to send(described_matcher, "foo")
    }.to raise_error(JsonMatchers::InvalidSchemaError)
  end

  it "does not fail with an empty JSON body" do
    create_schema("foo", {})

    expect(send(file_helper, {})).to send(described_matcher, "foo")
  end

  it "fails when the body is missing a required property" do
    create_schema("foo_schema", {
      "type" => "object",
      "required" => ["foo"],
    })

    expect(send(file_helper, {})).not_to send(described_matcher, "foo_schema")
  end

  it "accepts options for the validator" do
    create_schema("foo_schema", {
      "type" => "object",
      "required" => [
        "id",
      ],
      "properties" => {
        "id" => { "type" => "number" },
        "title" => {"type" => "string"},
      },
      "additionalProperties" => false,
    })

    expect(send(file_helper, { "id" => 1, "title" => "bar" })).
      to send(described_matcher, "foo_schema", strict: false)
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("foo_schema", {
      "type" => "object",
      "properties" => {
        "foo" => { "type" => "string" },
      }
    })

    expect(send(file_helper, "foo" => 1)).
      not_to send(described_matcher, "foo_schema")
  end

  it "contains the body in the failure message" do
    create_schema("foo", { "type" => "array" })

    expect {
      expect(send(file_helper, "bar" => 5)).to send(described_matcher, "foo")
    }.to raise_error(/{"bar":5}/)
  end

  it "contains the body in the failure message when negated" do
    create_schema("foo", { "type" => "array" })

    expect {
      expect(send(file_helper, [])).not_to send(described_matcher, "foo")
    }.to raise_error(/\[\]/)
  end

  it "contains the schema in the failure message" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(send(file_helper, "bar" => 5)).to send(described_matcher, "foo")
    }.to raise_error(/#{schema.to_json}/)
  end

  it "contains the schema in the failure message when negated" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(send(file_helper, [])).not_to send(described_matcher, "foo")
    }.to raise_error(/#{schema.to_json}/)
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      "type" => "array",
      "items" => { "type" => "string" },
    })

    expect(send(file_helper, ["valid"])).to send(described_matcher, "array_schema")
  end

  it "supports $ref" do
    create_schema("single", {
      "type" => "object",
      "required" => ["foo"],
      "properties" => {
        "foo" => { "type" => "string" },
      }
    })
    create_schema("collection", {
      "type" => "array",
      "items" => { "$ref" => "single.json" },
    })

    valid_response = send(file_helper, [{ "foo" => "is a string" }])
    invalid_response = send(file_helper, [{ "foo" => 0 }])

    expect(valid_response).to send(described_matcher, "collection")
    expect(invalid_response).not_to send(described_matcher, "collection")
  end
end
