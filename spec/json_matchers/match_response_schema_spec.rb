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
      "type": "object",
      "required": ["foo"],
    })

    expect(response_for({})).not_to match_response_schema("foo_schema")
  end

  context "when passed a Hash" do
    it "validates when the schema matches" do
      create_schema("foo_schema", {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
          "title": {"type": "string"},
        },
        "additionalProperties": false,
      })

      expect(response_for({ "id": 1, "title": "bar" })).
        to match_response_schema("foo_schema")
    end

    it "fails with message when negated" do
      create_schema("foo_schema", {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })

      expect {
        expect({ "id": "1" }).to match_response_schema("foo_schema")
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  context "when passed a Array" do
    it "validates when the schema matches" do
      create_schema("foo_schema", {
        "type": "array",
        "items": {
          "required": [
            "id",
          ],
          "properties": {
            "id": { "type": "number" },
          },
          "additionalProperties": false,
        }
      })

      expect([{ "id": 1 }]).to match_response_schema("foo_schema")
    end

    it "fails with message when negated" do
      create_schema("foo_schema", {
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
        }
      })

      expect {
        expect([{ "id": "1" }]).to match_response_schema("foo_schema")
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  context "when JSON is a string" do
    before(:each) do
      create_schema("foo_schema", {
        "type": "object",
        "required": [
          "id",
        ],
        "properties": {
          "id": { "type": "number" },
        },
        "additionalProperties": false,
      })
    end

    it "validates when the schema matches" do
      expect({ "id": 1 }.to_json).
        to match_response_schema("foo_schema")
    end

    it "fails with message when negated" do
      expect {
        expect({ "id": "1" }.to_json).to match_response_schema("foo_schema")
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
  end

  it "fails when the body contains a property with the wrong type" do
    create_schema("foo_schema", {
      "type": "object",
      "properties": {
        "foo": { "type": "string" },
      }
    })

    expect(response_for("foo": 1)).
      not_to match_response_schema("foo_schema")
  end

  it "contains the body in the failure message" do
    create_schema("foo", { "type": "array" })

    expect {
      expect(response_for("bar": 5)).to match_response_schema("foo")
    }.to raise_formatted_error(%{{ "bar": 5 }})
  end

  it "contains the body in the failure message when negated" do
    create_schema("foo", { "type": "array" })

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_formatted_error("[ ]")
  end

  it "contains the schema in the failure message" do
    schema = { "type": "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for("bar": 5)).to match_response_schema("foo")
    }.to raise_formatted_error(%{{ "type": "array" }})
  end

  it "contains the schema in the failure message when negated" do
    schema = { "type": "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_formatted_error(%{{ "type": "array" }})
  end

  it "does not fail when the schema matches" do
    create_schema("array_schema", {
      "type": "array",
      "items": { "type": "string" },
    })

    expect(response_for(["valid"])).to match_response_schema("array_schema")
  end

  it "supports $ref" do
    create_schema("user", {
      "id": "file:/#{JsonMatchers.schema_root}/user.json#",
      "type": "object",
      "required": ["id"],
      "properties": {
        "id": {
          "type": "integer"
        }
      }
    })
    create_schema("users", {
      "id": "file:/#{JsonMatchers.schema_root}/users.json#",
      "type": "object",
      "definitions": {
        "users": {
          "description": "A collection of users",
          "example": [{ "id": "1" }],
          "type": "array",
          "items": { "$ref": "file:/#{JsonMatchers.schema_root}/user.json#" }
        }
      },
      "required": ["users"],
      "properties": { "users": { "$ref": "#/definitions/users" } }
    })

    valid_response = response_for({ "users": [{ "id": 1 }] })
    invalid_response = response_for({ "users": [{ "id": "invalid" }]})

    expect(valid_response).to match_response_schema("users")
    expect(invalid_response).not_to match_response_schema("users")
  end

  it "supports the 'id' keyword" do
    create_schema("top-level-schema", {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "type": "object",
      "properties": {
        "a": { "$ref": "file:/#{JsonMatchers.schema_root}/nested.json#" }
      }
    })
    create_schema("nested-schema", {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "id": "file:/#{JsonMatchers.schema_root}/nested.json#",
      "type": "object",
      "required": ["b"],
      "properties": { "b": { "type": "string" } },
    })
    response_json = { a: { b: "foo" } }
    invalid_response_json = { a: { b: 4 } }

    expect(response_for(response_json)).
      to match_response_schema("top-level-schema")
    expect(response_for(invalid_response_json)).
      not_to match_response_schema("top-level-schema")
  end

  context "when options are passed directly to the matcher" do
    it "forwards options to the validator" do
      create_schema("foo_schema", {
        "type": "object",
        "properties": {
          "id": { "type": "number" },
          "title": { "type": "string" },
        },
      })

      expect(response_for({ "id": 1, "title": "bar" })).
        to match_response_schema("foo_schema", strict: true)
      expect(response_for({ "id": 1 })).
        not_to match_response_schema("foo_schema", strict: true)
    end
  end

  context "when options are configured globally" do
    it "forwards them to the validator" do
      with_options(strict: true) do
        create_schema("foo_schema", {
          "type": "object",
          "properties": {
            "id": { "type": "number" },
            "title": { "type": "string" },
          },
        })

        expect(response_for({ "id": 1, "title": "bar" })).
          to match_response_schema("foo_schema")
        expect(response_for({ "id": 1 })).
          not_to match_response_schema("foo_schema")
      end
    end

    context "when configured to record errors" do
      it "includes the reasons for failure in the exception's message" do
        with_options(record_errors: true) do
          create_schema("foo_schema", {
            "type": "object",
            "properties": {
              "username": {
                "allOf": [
                  { "type": "string" },
                  { "minLength": 5 }
                ]
              }
            }
          })
          invalid_payload = response_for({ "username": "foo" })

          expect {
            expect(invalid_payload).to match_response_schema("foo_schema")
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
