describe JSON::Matchers, "#match_response_schema" do
  it "fails with an invalid JSON body" do
    create_schema("foo", "")

    expect {
      expect(response_for("")).to match_response_schema("foo")
    }.to raise_error(JSON::Matchers::InvalidError)
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

    expect(response_for({})).not_to match_response_schema("array_schema")
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("array_schema", {
      type: "object",
      properties: {
        foo: { type: "string" }
      }
    })

    expect(response_for({foo: 1})).not_to match_response_schema("array_schema")
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      type: "array",
      items: { type: "string" }
    })

    expect(response_for(["valid"])).to match_response_schema("array_schema")
  end

  it "supports $ref" do
    create_schema "foo", <<-JSON.strip_heredoc
    {
      "type": "object",
      "properties": {
        "foo": { "type": "string" }
      }
    }
    JSON
    create_schema "foos", <<-JSON.strip_heredoc
    {
      "type": "array",
      "items": { "$ref": "foo.json" }
    }
    JSON

    valid_response = response_for([{foo: "is a string"}])
    invalid_response = response_for([{foo: 0}])

    expect(valid_response).to match_response_schema("foos")
    expect(invalid_response).not_to match_response_schema("foos")
  end
end
