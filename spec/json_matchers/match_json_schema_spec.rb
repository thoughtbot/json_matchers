describe JsonMatchers, "#match_json_schema" do
  it "fails with an invalid JSON schema" do
    schema = create(:schema, :invalid)

    json = build(:response)

    expect {
      expect(json).to match_json_schema(schema)
    }.to raise_error(JsonMatchers::InvalidSchemaError)
  end

  it "does not fail with an empty JSON body" do
    schema = create(:schema, {})

    json = build(:response, {})

    expect(json).to match_json_schema(schema)
  end

  it "fails when the body is missing a required property" do
    schema = create(:schema, {
      "type": "object",
      "required": ["foo"],
    })

    json = build(:response, {})

    expect(json).not_to match_json_schema(schema)
  end

  context "when passed a Hash" do
    it "validates when the schema matches" do
      schema = create(:schema, {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })

      json = { "id": 1 }

      expect(json).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })

      json = { "id": "1" }

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  context "when passed a Array" do
    it "validates when the schema matches" do
      schema = create(:schema, {
        "type": "array",
        "items": {
          "required": [
            "id",
          ],
          "properties": {
            "id": { "type": "number" },
          },
          "additionalProperties": false,
        },
      })

      json = [{ "id": 1 }]

      expect(json).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, {
        "type": "array",
        "items": {
          "type": "object",
          "required": [
            "id",
          ],
          "properties": {
            "id": { "type": "number" },
          },
          "additionalProperties": false,
        },
      })

      json = [{ "id": "1" }]

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  context "when JSON is a string" do
    it "validates when the schema matches" do
      schema = create(:schema, {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })

      json = { "id": 1 }.to_json

      expect(json).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })

      json = { "id": "1" }.to_json

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  it "fails when the body contains a property with the wrong type" do
    schema = create(:schema, {
      "type": "object",
      "properties": {
        "foo": { "type": "string" },
      },
    })

    json = build(:response, { "foo": 1 })

    expect(json).not_to match_json_schema(schema)
  end

  it "contains the body in the failure message" do
    schema = create(:schema, { "type": "array" })

    json = build(:response, { "bar": 5 })

    expect {
      expect(json).to match_json_schema(schema)
    }.to raise_formatted_error(%{{ "bar": 5 }})
  end

  it "contains the body in the failure message when negated" do
    schema = create(:schema, { "type": "array" })

    json = build(:response, body: "[]")

    expect {
      expect(json).not_to match_json_schema(schema)
    }.to raise_formatted_error("[ ]")
  end

  it "contains the schema in the failure message" do
    schema = create(:schema, { "type": "array" })

    json = build(:response, { "bar": 5 })

    expect {
      expect(json).to match_json_schema(schema)
    }.to raise_formatted_error(%{{ "type": "array" }})
  end

  it "contains the schema in the failure message when negated" do
    schema = create(:schema, { "type": "array" })

    json = build(:response, body: "[]")

    expect {
      expect(json).not_to match_json_schema(schema)
    }.to raise_formatted_error(%{{ "type": "array" }})
  end

  it "does not fail when the schema matches" do
    schema = create(:schema, {
      "type": "array",
      "items": { "type": "string" },
    })

    json = build(:response, body: ["valid"])

    expect(json).to match_json_schema(schema)
  end

  it "supports $ref" do
    nested = create(:schema, {
      "type": "object",
      "required": ["foo"],
      "properties": {
        "foo": { "type": "string" },
      },
    })
    collection = create(:schema, {
      "type": "array",
      "items": { "$ref": "#{nested.name}.json" },
    })

    valid_response = build(:response, body: [{ "foo": "is a string" }])
    invalid_response = build(:response, body: [{ "foo": 0 }])

    expect(valid_response).to match_json_schema(collection)
    expect(valid_response).to match_response_schema(collection)
    expect(invalid_response).not_to match_json_schema(collection)
    expect(invalid_response).not_to match_response_schema(collection)
  end

  context "when options are passed directly to the matcher" do
    it "forwards options to the validator" do
      schema = create(:schema, {
        "type": "object",
        "properties": {
          "id": { "type": "number" },
          "title": { "type": "string" },
        },
      })

      matching_json = build(:response, { "id": 1, "title": "bar" })
      invalid_json = build(:response, { "id": 1 })

      expect(matching_json).to match_json_schema(schema, strict: true)
      expect(invalid_json).not_to match_json_schema(schema, strict: true)
    end
  end

  context "when options are configured globally" do
    it "forwards them to the validator" do
      with_options(strict: true) do
        schema = create(:schema, {
          "type": "object",
          "properties": {
            "id": { "type": "number" },
            "title": { "type": "string" },
          },
        })

        matching_json = build(:response, { "id": 1, "title": "bar" })
        invalid_json = build(:response, { "id": 1 })

        expect(matching_json).to match_json_schema(schema)
        expect(invalid_json).not_to match_json_schema(schema)
      end
    end

    context "when configured to record errors" do
      it "includes the reasons for failure in the exception's message" do
        with_options(record_errors: true) do
          schema = create(:schema, {
            "type": "object",
            "properties": {
              "username": {
                "allOf": [
                  { "type": "string" },
                  { "minLength": 5 },
                ],
              },
            },
          })

          invalid_json = build(:response, { "username": "foo" })

          expect {
            expect(invalid_json).to match_json_schema(schema)
          }.to raise_error(/minimum/)
        end
      end
    end
  end

  def raise_formatted_error(error_message)
    raise_error do |error|
      sanitized_message = error.message.
        gsub(/\A[[:space:]]+/, "").
        gsub(/[[:space:]]+\z/, "").
        gsub(/[[:space:]]+/, " ")

      expect(sanitized_message).to include(error_message)
    end
  end
end
