require "json_matchers/payload"
require_relative "./support/fake_response"
require_relative "./support/fake_schema"

FactoryBot.define do
  factory :response, class: FakeResponse do
    skip_create

    trait :location do
      body { { "latitude": 1, "longitude": 1 } }
    end

    trait :invalid_location do
      body { { "latitude": "1", "longitude": "1" } }
    end

    initialize_with do
      body = attributes.fetch(:body, nil)
      json = attributes.except(:body)
      payload = JsonMatchers::Payload.new(body || json)

      FakeResponse.new(payload.to_s)
    end
  end

  factory :schema, class: FakeSchema do
    sequence(:name) { |n| "json_schema-#{n}" }

    trait :invalid do
      json { "" }
    end

    trait :location do
      json do
        {
          "id": "file:/#{name}.json#",
          "description": "An object containing some #{name} data",
          "type": "object",
          "required": ["latitude", "longitude"],
          "properties": {
            "latitude": {
              "type": "number",
            },
            "longitude": {
              "type": "number",
            },
          },
          "additionalProperties": false,
        }
      end
    end
    trait(:locations) { location }

    trait :array_of do
      initialize_with do
        schema_body_as_json = attributes.fetch(:json, nil)
        schema_body = attributes.except(:json, :name)

        FakeSchema.new(name, {
          "type": "array",
          "items": schema_body_as_json || schema_body,
        })
      end
    end

    trait :referencing_locations do
      association :items, factory: [:schema, :location]

      initialize_with do
        FakeSchema.new(name, {
          "id": "file:/#{name}.json#",
          "$schema": "https://json-schema.org/draft-04/schema#",
          "type": "array",
          "items": { "$ref": "file:/#{items.name}.json#" },
        })
      end
    end

    trait :referencing_definitions do
      association :items, factory: [:schema, :location], name: "location"
      association :example, factory: [:response, :location]

      transient do
        plural { items.name.pluralize }
      end

      json do
        {
          "$schema": "https://json-schema.org/draft-04/schema#",
          "id": "file:/#{name}.json#",
          "type": "object",
          "definitions": {
            plural => {
              "type": "array",
              "items": { "$ref": "file:/#{items.name}.json#" },
              "description": "A collection of #{plural}",
              "example": example,
            },
          },
          "required": [plural],
          "properties": {
            plural => {
              "$ref": "#/definitions/#{plural}",
            },
          },
        }
      end
    end

    initialize_with do
      schema_body_as_json = attributes.fetch(:json, nil)
      schema_body = attributes.except(:json, :name)

      FakeSchema.new(name, schema_body_as_json || schema_body)
    end

    to_create do |schema|
      path = JsonMatchers.path_to_schema(schema.name)
      payload = JsonMatchers::Payload.new(schema.json)

      path.dirname.mkpath
      IO.write(path, payload)
    end
  end
end
