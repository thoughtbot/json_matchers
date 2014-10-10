require "shoulda/matchers/json/schema_parser"

describe Shoulda::Matchers::Json::SchemaParser do
  describe "#schema_for" do
    it "returns the JSON string for a given schema" do
      create_schema("foo", { type: "array" })

      schema_parser = Shoulda::Matchers::Json::SchemaParser.new(schema_root)

      expect(schema_parser.schema_for("foo")).to eq '{"type":"array"}'
    end

    it "can embed other schemas" do
      create_schema "post", <<-JSON.strip
      {
        "type": "object",
        "required": ["id", "title", "body"],
        "properties": {
          "id": { "type": "integer" },
          "title": { "type": "string" },
          "body": { "type": "string" }
        }
      }
      JSON
      create_schema "posts", <<-JSON.strip
      {
        "type": "object",
        "required": ["posts"],
        "properties": {
          "posts": {
            "type": "array",
            "items": <%= schema_for("post") %>
          }
        }
      }
      JSON

      schema_parser = Shoulda::Matchers::Json::SchemaParser.new(schema_root)
      schema = schema_parser.schema_for("posts")

      expect(JSON.parse(schema)).to eq({
        "type" => "object",
        "required" => ["posts"],
        "properties" => {
          "posts" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "required" => ["id", "title", "body"],
              "properties" => {
                "id" => { "type" => "integer" },
                "title" => { "type" => "string" },
                "body" => { "type" => "string" }
              }
            }
          }
        }
      })
    end

    it "fails when the schema is missing" do
      schema_parser = Shoulda::Matchers::Json::SchemaParser.new(schema_root)
      expect {
        schema_parser.schema_for("missing")
      }.to raise_error(Shoulda::Matchers::Json::MissingSchema, /missing.json/)
    end
  end
end
