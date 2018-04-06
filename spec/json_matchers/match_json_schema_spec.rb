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
    schema = create(:schema, :object)

    json = build(:response, :invalid_object)

    expect(json).not_to match_response_schema(schema)
  end

  it "supports refuting with the match_response_schema alias" do
    schema = create(:schema, :object)

    json = build(:response, :invalid_object)

    expect(json).not_to match_response_schema(schema)
  end

  it "fails when the body contains a property with the wrong type" do
    schema = create(:schema, :object)

    json = build(:response, :invalid_object)

    expect(json).not_to match_json_schema(schema)
  end

  it "fails when the body is missing a required property" do
    schema = create(:schema, :object)

    json = build(:response, {})

    expect(json).not_to match_json_schema(schema)
  end

  context "when passed a Hash" do
    it "validates that the schema matches" do
      schema = create(:schema, :object)

      json = build(:response, :object)
      json_as_hash = json.to_h

      expect(json_as_hash).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :object)

      json = build(:response, :invalid_object)
      json_as_hash = json.to_h

      expect {
        expect(json_as_hash).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  context "when passed a Array" do
    it "validates a root-level Array in the JSON" do
      schema = create(:schema, :array_of, :objects)

      json = build(:response, :object)
      json_as_array = [json.to_h]

      expect(json_as_array).to match_json_schema(schema)
    end

    it "refutes a root-level Array in the JSON" do
      schema = create(:schema, :array_of, :objects)

      json = build(:response, :invalid_object)
      json_as_array = [json.to_h]

      expect(json_as_array).not_to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :array_of, :object)

      json = build(:response, :invalid_object)
      json_as_array = [json.to_h]

      expect {
        expect(json_as_array).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  context "when JSON is a string" do
    it "validates that the schema matches" do
      schema = create(:schema, :object)

      json = build(:response, :object)
      json_as_string = json.to_json

      expect(json_as_string).to match_json_schema(schema)
    end

    it "fails with message when negated" do
      schema = create(:schema, :object)

      json = build(:response, :invalid_object)
      json_as_string = json.to_json

      expect {
        expect(json_as_string).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  it "fails when the body contains a property with the wrong type" do
    schema = create(:schema, :object)

    json = build(:response, :invalid_object)

    expect(json).not_to match_json_schema(schema)
  end

  describe "the failure message" do
    it "contains the body" do
      schema = create(:schema, :object)

      json = build(:response, :invalid_object)

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_error_containing(json)
    end

    it "contains the schema" do
      schema = create(:schema, :object)

      json = build(:response, :invalid_object)

      expect {
        expect(json).to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end

    it "when negated, contains the body" do
      schema = create(:schema, :object)

      json = build(:response, :object)

      expect {
        expect(json).not_to match_json_schema(schema)
      }.to raise_error_containing(json)
    end

    it "when negated, contains the schema" do
      schema = create(:schema, :object)

      json = build(:response, :object)

      expect {
        expect(json).not_to match_json_schema(schema)
      }.to raise_error_containing(schema)
    end
  end

  it "validates against a schema that uses $ref" do
    schema = create(:schema, :referencing_objects)

    json = build(:response, :object)
    json_as_array = [json.to_h]

    expect(json_as_array).to match_json_schema(schema)
  end

  it "fails against a schema that uses $ref" do
    schema = create(:schema, :referencing_objects)

    json = build(:response, :invalid_object)
    json_as_array = [json.to_h]

    expect(json_as_array).not_to match_json_schema(schema)
  end

  context "when options are passed directly to the matcher" do
    it "forwards options to the validator" do
      schema = create(:schema, :object)

      matching_json = build(:response, :object)
      invalid_json = build(:response, { "id": 1, "title": "bar" })

      expect(matching_json).to match_json_schema(schema, strict: true)
      expect(invalid_json).not_to match_json_schema(schema, strict: true)
    end
  end

  context "when options are configured globally" do
    it "forwards them to the validator" do
      with_options(strict: true) do
        schema = create(:schema, :object)

        matching_json = build(:response, :object)
        invalid_json = build(:response, { "id": 1, "title": "bar" })

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

  def raise_error_containing(schema_or_body)
    raise_error do |error|
      sanitized_message = error.message.squish
      json = JSON.pretty_generate(schema_or_body.to_h)
      error_message = json.squish

      expect(sanitized_message).to include(error_message)
    end
  end
end
