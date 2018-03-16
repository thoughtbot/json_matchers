require "fileutils"
require "json"

FakeSchema = Struct.new(:name, :json) do
  def to_s
    name
  end
end

FactoryBot.define do
  factory :schema, class: FakeSchema do
    sequence(:name) { |n| "json_schema-#{n}" }

    trait :invalid do
      json { "" }
    end

    skip_create
    initialize_with do
      name = attributes.fetch(:name)
      json_attribute = attributes[:json]
      attributes_as_json = attributes.except(:json, :name)

      FakeSchema.new(name, json_attribute || attributes_as_json)
    end

    after :create do |schema, evaluator|
      path = File.join(JsonMatchers.schema_root, "#{schema.name}.json")
      json = schema.json

      File.open(path, "w") do |file|
        case json
        when NilClass, String
          file.write(json.to_s)
        else
          file.write(JSON.generate(json))
        end
      end
    end
  end
end
