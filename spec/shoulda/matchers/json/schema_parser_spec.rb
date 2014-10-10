require "shoulda/matchers/json/schema_parser"

describe Shoulda::Matchers::Json::SchemaParser do
  describe "#schema_for" do
    it "returns the JSON string for a given schema" do
      create_schema("foo", { type: "array" })

      schema_parser = Shoulda::Matchers::Json::SchemaParser.new(schema_root)

      expect(schema_parser.schema_for("foo")).to eq '{"type":"array"}'
    end

    it "can embed other schemas" do
      create_schema "foo", <<-JSON.strip
      {
        "type": "object",
        "properties": {
          "bar": { "type": "boolean" }
        }
      }
      JSON
      create_schema "foos", <<-JSON.strip
      {
        "type": "object",
        "properties": {
          "foos": {
            "type": "array",
            "items": <%= schema_for("foo") %>
          }
        }
      }
      JSON

      schema_parser = Shoulda::Matchers::Json::SchemaParser.new(schema_root)
      schema = schema_parser.schema_for("foos")

      expect(JSON.parse(schema)).to eq({
        "type" => "object",
        "properties" => {
          "foos" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "properties" => {
                "bar" => { "type" => "boolean" }
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
