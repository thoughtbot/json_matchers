require "json_matchers/payload"

FactoryBot.define do
  FakeResponse = Struct.new(:body)
  FakeSchema = Struct.new(:name, :json) do
    def to_s
      name
    end
  end

  factory :response, class: FakeResponse do
    skip_create

    initialize_with do
      body = attributes[:body]
      payload = attributes.except(:body)

      FakeResponse.new(body || payload.to_json)
    end
  end

  factory :schema, class: FakeSchema do
    sequence(:name) { |n| "json_schema-#{n}" }

    trait :invalid do
      json { "" }
    end

    skip_create

    initialize_with do
      name = attributes.fetch(:name)
      json_attribute = attributes.fetch(:json, nil)
      attributes_as_json = attributes.except(:json, :name)

      FakeSchema.new(name, json_attribute || attributes_as_json)
    end

    after :create do |schema|
      path = File.join(JsonMatchers.schema_root, "#{schema.name}.json")
      payload = JsonMatchers::Payload.new(schema.json)

      IO.write(path, payload)
    end
  end
end
