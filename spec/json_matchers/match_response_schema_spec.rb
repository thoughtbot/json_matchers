describe JsonMatchers, "#match_response_schema" do
  it "fails with an invalid JSON body" do
    create_schema("foo", "")

    expect {
      expect(response_for("")).to match_response_schema("foo")
    }.to raise_error(JsonMatchers::InvalidSchemaError)
  end

  it "does not fail with an empty JSON body" do
    create_schema("foo", {})

    expect(response_for({})).to match_response_schema("foo")
  end

  it "fails when the body is missing a required property" do
    create_schema("foo_schema", {
      "type" => "object",
      "required" => ["foo"],
    })

    expect(response_for({})).not_to match_response_schema("foo_schema")
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

    expect(response_for({ "id" => 1, "title" => "bar" })).
      to match_response_schema("foo_schema", strict: false)
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("foo_schema", {
      "type" => "object",
      "properties" => {
        "foo" => { "type" => "string" },
      }
    })

    expect(response_for("foo" => 1)).
      not_to match_response_schema("foo_schema")
  end

  it "contains the body in the failure message" do
    create_schema("foo", { "type" => "array" })

    expect {
      expect(response_for("bar" => 5)).to match_response_schema("foo")
    }.to raise_error(/{"bar":5}/)
  end

  it "contains the body in the failure message when negated" do
    create_schema("foo", { "type" => "array" })

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_error(/\[\]/)
  end

  it "contains the schema in the failure message" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for("bar" => 5)).to match_response_schema("foo")
    }.to raise_error(/#{schema.to_json}/)
  end

  it "contains the schema in the failure message when negated" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_error(/#{schema.to_json}/)
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      "type" => "array",
      "items" => { "type" => "string" },
    })

    expect(response_for(["valid"])).to match_response_schema("array_schema")
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

    valid_response = response_for([{ "foo" => "is a string" }])
    invalid_response = response_for([{ "foo" => 0 }])

    expect(valid_response).to match_response_schema("collection")
    expect(invalid_response).not_to match_response_schema("collection")
  end

  it "works when a pure string is used for response" do
    create_schema("foo_schema", {
      "type" => "object",
      "required" => [
        "id",
      ],
      "properties" => {
        "id" => { "type" => "number" },
        "title" => { "type" => "string" },
      },
      "additionalProperties" => false,
    })

    expect({ "id" => 1, "title" => "bar" }.to_json).
      to match_response_schema("foo_schema", strict: false)
  end
end
