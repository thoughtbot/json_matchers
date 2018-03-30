require "json_matchers/payload"

FactoryBot.define do
  FakeResponse = Struct.new(:body) do
    def to_h
      JSON.parse(body)
    end
  end
  FakeSchema = Struct.new(:name, :json) do
    def to_h
      json
    end

    def to_s
      name
    end
  end

  factory :response, class: FakeResponse do
    skip_create

    initialize_with do
      body = attributes.fetch(:body, nil)
      payload = attributes.except(:body)

      FakeResponse.new(body || payload.to_json)
    end
  end

  factory :schema, class: FakeSchema do
    sequence(:name) { |n| "json_schema-#{n}" }

    trait :invalid do
      json { "" }
    end

    trait :with_id do
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
    trait(:with_ids) { with_id }

    trait :array do
      initialize_with do
        schema_body_as_json = attributes.fetch(:json, nil)
        schema_body = attributes.except(:json, :name)

        FakeSchema.new(name, {
          "type": "array",
          "items": schema_body_as_json || schema_body,
        })
      end
    end

    skip_create

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
