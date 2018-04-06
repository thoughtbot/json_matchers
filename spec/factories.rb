require "json_matchers/payload"
require_relative "./support/fake_response"
require_relative "./support/fake_schema"

FactoryBot.define do
  factory :response, class: FakeResponse do
    skip_create

    trait :object do
      body { { "id": 1 } }
    end

    trait :invalid_object do
      body { { "id": "1" } }
    end

    initialize_with do
      body = attributes.fetch(:body, nil)
      json = attributes.except(:body)
      payload = JsonMatchers::Payload.new(body || json)

      FakeResponse.new(payload.to_s)
    end
  end

  factory :schema, class: FakeSchema do
    skip_create

    sequence(:name) { |n| "json_schema-#{n}" }

    trait :invalid do
      json { "" }
    end

    trait :object do
      json do
        {
          "type": "object",
          "required": [
            "id",
          ],
          "properties": {
            "id": { "type": "number" },
          },
          "additionalProperties": false,
        }
      end
    end
    trait(:objects) { object }

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

    trait :referencing_objects do
      association :items, factory: [:schema, :object]

      initialize_with do
        FakeSchema.new(name, {
          "type": "array",
          "items": { "$ref": "#{items.name}.json" },
        })
      end
    end

    initialize_with do
      schema_body_as_json = attributes.fetch(:json, nil)
      schema_body = attributes.except(:json, :name)

      FakeSchema.new(name, schema_body_as_json || schema_body)
    end

    after :create do |schema|
      path = File.join(JsonMatchers.schema_root, "#{schema.name}.json")
      payload = JsonMatchers::Payload.new(schema.json)

      IO.write(path, payload)
    end
  end
end
