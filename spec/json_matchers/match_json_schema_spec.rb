require "active_support/core_ext/string"

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

  it "supports asserting with the match_response_schema alias" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    expect(json).not_to match_response_schema(schema)
  end

  it "supports refuting with the match_response_schema alias" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    expect(json).not_to match_response_schema(schema)
  end

  it "fails when the body contains a property with the wrong type" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    expect(json).not_to match_json_schema(schema)
  end

  it "fails when the body is missing a required property" do
    schema = create(:schema, :location)

    json = build(:response, {})

    expect(json).not_to match_json_schema(schema)
  end

  it "can reference a schema in a directory" do
    create(:schema, :location, name: "api/v1/schema")

    json = build(:response, :location)

    expect(json).to match_json_schema("api/v1/schema")
  end

  it "supports invalidating the referenced schema when using local references" do
    create(:schema, name: "post", json: {
      "$schema": "https://json-schema.org/draft-04/schema#",
      "id": "file:/post.json#",
      "definitions": {
        "attributes": {
          "type": "object",
          "required": [
            "id",
            "name",
          ],
          "properties": {
            "id": { "type": "string" },
            "name": { "type": "string" }
          }
        }
      },
      "type": "object",
      "required": [
        "id",
        "type",
        "attributes"
      ],
      "properties": {
        "id": { "type": "string" },
        "type": { "type": "string" },
        "attributes": {
          "$ref": "#/definitions/attributes",
        }
      }
    })
    posts_index = create(:schema, name: "posts/index", json: {
      "$schema": "https://json-schema.org/draft-04/schema#",
      "id": "file:/posts/index.json#",
      "type": "object",
      "required": [
        "data"
      ],
      "definitions": {
        "posts": {
          "type": "array",
          "items": {
            "$ref": "file:/post.json#"
          }
        }
      },
      "properties": {
        "data": {
          "$ref": "#/definitions/posts"
        }
      }
    })

    json = build(:response, {
      "data": [{
        "id": "1",
        "type": "Post",
        "attributes": {
          "id": 1,
          "name": "The Post's Name"
        }
      }]
    })

    expect(json).not_to match_json_schema(posts_index)
  end

  it "can reference a schema relatively" do
    create(:schema, name: "post", json: {
      "$schema": "https://json-schema.org/draft-04/schema#",
      "id": "file:/post.json#",
      "type": "object",
      "required": [
        "id",
        "type",
        "attributes"
      ],
      "properties": {
        "id": { "type": "string" },
        "type": { "type": "string" },
        "attributes": {
          "type": "object",
          "required": [
            "id",
            "name"
          ],
          "properties": {
            "id": { "type": "string" },
            "name": { "type": "string" },
            "user": {
              "type": "object",
              "required": [
                "id"
              ],
              "properties": {
                "id": { "type": "string" }
              }
            }
          }
        }
      }
    })
    posts_index = create(:schema, name: "posts/index", json: {
      "$schema": "https://json-schema.org/draft-04/schema#",
      "id": "file:/posts/index.json#",
      "type": "object",
      "required": [
        "data"
      ],
      "definitions": {
        "posts": {
          "type": "array",
          "items": {
            "$ref": "file:/post.json#"
          }
        }
      },
      "properties": {
        "data": {
          "$ref": "#/definitions/posts"
        }
      }
    })

    json = build(:response, {
      "data": [{
        "id": "1",
        "type": "Post",
        "attributes": {
          "id": "1",
          "name": "The Post's Name",
          "user": {
            "id": "1"
          }
        }
      }]
    })

    expect(json).to match_json_schema(posts_index)
  end

  context "when passed a Hash" do
    it "validates that the schema matches" do
      schema = create(:schema, :location)

      json = build(:response, :location)
      json_as_hash = json.to_h

      expect(json_as_hash).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :location)

      json = build(:response, :invalid_location)
      json_as_hash = json.to_h

      expect {
        expect(json_as_hash).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  context "when passed a Array" do
    it "validates a root-level Array in the JSON" do
      schema = create(:schema, :array_of, :locations)

      json = build(:response, :location)
      json_as_array = [json.to_h]

      expect(json_as_array).to match_json_schema(schema)
    end

    it "refutes a root-level Array in the JSON" do
      schema = create(:schema, :array_of, :locations)

      json = build(:response, :invalid_location)
      json_as_array = [json.to_h]

      expect(json_as_array).not_to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :array_of, :location)

      json = build(:response, :invalid_location)
      json_as_array = [json.to_h]

      expect {
        expect(json_as_array).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  context "when JSON is a string" do
    it "validates that the schema matches" do
      schema = create(:schema, :location)

      json = build(:response, :location)
      json_as_string = json.to_json

      expect(json_as_string).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :location)

      json = build(:response, :invalid_location)
      json_as_string = json.to_json

      expect {
        expect(json_as_string).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  it "fails when the body contains a property with the wrong type" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    expect(json).not_to match_json_schema(schema)
  end

  describe "the failure message" do
    it "contains the body" do
      schema = create(:schema, :location)

      json = build(:response, :invalid_location)

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_error_containing(json)
    end

    it "contains the schema" do
      schema = create(:schema, :location)

      json = build(:response, :invalid_location)

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end

    it "when negated, contains the body" do
      schema = create(:schema, :location)

      json = build(:response, :location)

      expect {
        expect(json).not_to match_json_schema(schema)
      }.to raise_error_containing(json)
    end

    it "when negated, contains the schema" do
      schema = create(:schema, :location)

      json = build(:response, :location)

      expect {
        expect(json).not_to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  it "validates against a schema that uses $ref" do
    schema = create(:schema, :referencing_locations)

    json = build(:response, :location)
    json_as_array = [json.to_h]

    expect(json_as_array).to match_json_schema(schema)
  end

  it "fails against a schema that uses $ref" do
    schema = create(:schema, :referencing_locations)

    json = build(:response, :invalid_location)
    json_as_array = [json.to_h]

    expect(json_as_array).not_to match_json_schema(schema)
  end

  it "validates against a schema that uses nested $refs" do
    items = create(:schema, :referencing_locations)
    schema = create(:schema, :referencing_locations, items: items)

    json = build(:response, :location)
    json_as_array = [[json.to_h]]

    expect(json_as_array).to match_json_schema(schema)
  end

  it "fails against a schema that uses nested $refs" do
    items = create(:schema, :referencing_locations)
    schema = create(:schema, :referencing_locations, items: items)

    json = build(:response, :invalid_location)
    json_as_array = [[json.to_h]]

    expect(json_as_array).not_to match_json_schema(schema)
  end

  it "validates against a schema referencing with 'definitions'" do
    schema = create(:schema, :referencing_definitions)

    json = build(:response, :location)
    json_as_hash = { "locations" => [json] }

    expect(json_as_hash).to match_json_schema(schema)
  end

  it "fails against a schema referencing with 'definitions'" do
    schema = create(:schema, :referencing_definitions)

    json = build(:response, :invalid_location)
    json_as_hash = { "locations" => [json] }

    expect(json_as_hash).not_to match_json_schema(schema)
  end

  def raise_error_containing(schema_or_body)
    raise_error do |error|
      sanitized_message = error.message.squish
      json = JSON.pretty_generate(schema_or_body.to_h)
      error_message = json.squish

      expect(sanitized_message).to include(error_message)
    end
  end
end
