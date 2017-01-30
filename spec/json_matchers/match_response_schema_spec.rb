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

  context "when JSON is a string" do
    before(:each) do
      create_schema("foo_schema", {
        "type" => "object",
        "required" => [
          "id",
        ],
        "properties" => {
          "id" => { "type" => "number" },
        },
        "additionalProperties" => false,
      })
    end

    it "validates when the schema matches" do
      expect({ "id" => 1 }.to_json).
        to match_response_schema("foo_schema")
    end

    it "fails with message when negated" do
      expect {
        expect({ "id" => "1" }.to_json).to match_response_schema("foo_schema")
      }.to raise_formatted_error(%{{ "type": "number" }})
    end
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
    }.to raise_formatted_error(%{{ "bar": 5 }})
  end

  it "contains the body in the failure message when negated" do
    create_schema("foo", { "type" => "array" })

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_formatted_error("[ ]")
  end

  it "contains the schema in the failure message" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for("bar" => 5)).to match_response_schema("foo")
    }.to raise_formatted_error(%{{ "type": "array" }})
  end

  it "contains the schema in the failure message when negated" do
    schema = { "type" => "array" }
    create_schema("foo", schema)

    expect {
      expect(response_for([])).not_to match_response_schema("foo")
    }.to raise_formatted_error(%{{ "type": "array" }})
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

  context "when options are passed directly to the matcher" do
    it "forwards options to the validator" do
      create_schema("foo_schema", {
        "type" => "object",
        "properties" => {
          "id" => { "type" => "number" },
          "title" => { "type" => "string" },
        },
      })

      expect(response_for({ "id" => 1, "title" => "bar" })).
        to match_response_schema("foo_schema", strict: true)
      expect(response_for({ "id" => 1 })).
        not_to match_response_schema("foo_schema", strict: true)
    end
  end

  context "when options are configured globally" do
    it "forwards them to the validator" do
      create_schema("foo_schema", {
        "type" => "object",
        "properties" => {
          "id" => { "type" => "number" },
          "title" => { "type" => "string" },
        },
      })

      JsonMatchers.configure do |config|
        config.options[:strict] = true
      end

      expect(response_for({ "id" => 1, "title" => "bar" })).
        to match_response_schema("foo_schema")
      expect(response_for({ "id" => 1 })).
        not_to match_response_schema("foo_schema")
    end

    after do
      JsonMatchers.configure do |config|
        config.options.delete(:strict)
      end
    end

    context "when options specify to record errors" do
      around do |example|
        JsonMatchers.configure do |config|
          config.options[:record_errors] = true
        end

        example.run

        JsonMatchers.configure do |config|
          config.options.delete(:record_errors)
        end
      end

      it "fails when the body is missing a required property" do
        create_schema("foo_schema",
                       "type" => "object",
                       "required" => ["foo"],
                     )

        expect(response_for({})).not_to match_response_schema("foo_schema")
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
