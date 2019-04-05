require_relative "../../test_helper"
require "active_support/core_ext/string"

class AssertResponseMatchesSchemaTest < JsonMatchers::TestCase
  test "fails with an invalid JSON schema" do
    schema = create(:schema, :invalid)

    json = build(:response)

    assert_raises JsonMatchers::InvalidSchemaError do
      assert_matches_json_schema(json, schema)
    end
  end

  test "does not fail with an empty JSON body" do
    schema = create(:schema, {})

    json = build(:response, {})

    assert_matches_json_schema(json, schema)
  end

  test "fails when the body contains a property with the wrong type" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    refute_matches_json_schema(json, schema)
  end

  test "fails when the body is missing a required property" do
    schema = create(:schema, :location)

    json = build(:response, {})

    refute_matches_json_schema(json, schema)
  end

  test "can reference a schema in a directory" do
    create(:schema, :location, name: "api/v1/schema")

    json = build(:response, :location)

    assert_matches_json_schema(json, "api/v1/schema")
  end

  test "supports invalidating the referenced schema when using local references" do
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

    refute_matches_json_schema(json, posts_index)
  end

  test "can reference a schema relatively" do
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

    assert_matches_json_schema(json, posts_index)
  end

  test "when passed a Hash, validates that the schema matches" do
    schema = create(:schema, :location)

    json = build(:response, :location)
    json_as_hash = json.to_h

    assert_matches_json_schema(json_as_hash, schema)
  end

  test "when passed a Hash, fails with message when negated" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)
    json_as_hash = json.to_h

    assert_raises_error_containing(schema) do
      assert_matches_json_schema(json_as_hash, schema)
    end
  end

  test "when passed a Array, validates a root-level Array in the JSON" do
    schema = create(:schema, :array_of, :locations)

    json = build(:response, :location)
    json_as_array = [json.to_h]

    assert_matches_json_schema(json_as_array, schema)
  end

  test "when passed a Array, refutes a root-level Array in the JSON" do
    schema = create(:schema, :array_of, :locations)

    json = build(:response, :invalid_location)
    json_as_array = [json.to_h]

    refute_matches_json_schema(json_as_array, schema)
  end

  test "when passed a Array, fails with message when negated" do
    schema = create(:schema, :array_of, :location)

    json = build(:response, :invalid_location)
    json_as_array = [json.to_h]

    assert_raises_error_containing(schema) do
      assert_matches_json_schema(json_as_array, schema)
    end
  end

  test "when JSON is a string, validates that the schema matches" do
    schema = create(:schema, :location)

    json = build(:response, :location)
    json_as_string = json.to_json

    assert_matches_json_schema(json_as_string, schema)
  end

  test "when JSON is a string, fails with message when negated" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)
    json_as_string = json.to_json

    assert_raises_error_containing(schema) do
      assert_matches_json_schema(json_as_string, schema)
    end
  end

  test "the failure message contains the body" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    assert_raises_error_containing(json) do
      assert_matches_json_schema(json, schema)
    end
  end

  test "the failure message contains the schema" do
    schema = create(:schema, :location)

    json = build(:response, :invalid_location)

    assert_raises_error_containing(schema) do
      assert_matches_json_schema(json, schema)
    end
  end

  test "the failure message when negated, contains the body" do
    schema = create(:schema, :location)

    json = build(:response, :location)

    assert_raises_error_containing(json) do
      refute_matches_json_schema(json, schema)
    end
  end

  test "the failure message when negated, contains the schema" do
    schema = create(:schema, :location)

    json = build(:response, :location)

    assert_raises_error_containing(schema) do
      refute_matches_json_schema(json, schema)
    end
  end

  test "asserts valid JSON against a schema that uses $ref" do
    schema = create(:schema, :referencing_locations)

    json = build(:response, :location)
    json_as_array = [json.to_h]

    assert_matches_json_schema(json_as_array, schema)
  end

  test "refutes valid JSON against a schema that uses $ref" do
    schema = create(:schema, :referencing_locations)

    json = build(:response, :invalid_location)
    json_as_array = [json.to_h]

    refute_matches_json_schema(json_as_array, schema)
  end

  test "validates against a schema that uses nested $refs" do
    items = create(:schema, :referencing_locations)
    schema = create(:schema, :referencing_locations, items: items)

    json = build(:response, :location)
    json_as_array = [[json.to_h]]

    assert_matches_json_schema(json_as_array, schema)
  end

  test "fails against a schema that uses nested $refs" do
    items = create(:schema, :referencing_locations)
    schema = create(:schema, :referencing_locations, items: items)

    json = build(:response, :invalid_location)
    json_as_array = [[json.to_h]]

    refute_matches_json_schema(json_as_array, schema)
  end


  test "validates against a schema referencing with 'definitions'" do
    schema = create(:schema, :referencing_definitions)

    json = build(:response, :location)
    json_as_hash = { "locations" => [json] }

    assert_matches_json_schema(json_as_hash, schema)
  end

  test "fails against a schema referencing with 'definitions'" do
    schema = create(:schema, :referencing_definitions)

    json = build(:response, :invalid_location)
    json_as_hash = { "locations" => [json] }

    refute_matches_json_schema(json_as_hash, schema)
  end

  def assert_raises_error_containing(schema_or_body)
    raised_error = assert_raises(Minitest::Assertion) do
      yield
    end

    sanitized_message = raised_error.message.squish
    json = JSON.pretty_generate(schema_or_body.to_h)
    error_message = json.squish

    assert_includes sanitized_message, error_message
  end
end
