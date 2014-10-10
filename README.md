# Shoulda::Matchers::Json

Validate your JSON APIs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shoulda-matchers-json', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shoulda-matchers-json

## Usage

Inspired by [Validating JSON Schemas with an RSpec Matcher](http://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher)

First, include it in your `spec_helper`:

```ruby
# spec/spec_helper.rb

require "shoulda/matchers"
require "shoulda/matchers/json"
```

First, define your [JSON Schema](http://json-schema.org/example1.html) in the schema directory:

```json
# spec/support/api/schemas/posts.json

{
  "type": "object",
  "required": ["posts"],
  "properties": {
    "type": "object",
    "required": ["id", "title", "body"],
    "properties": {
      "id": { "type": "integer" },
      "title": { "type": "string" },
      "body": { "type": "string" }
    }
  }
}
```

Then, validate your response against your schema with `match_response_schema`

```ruby
# spec/requests/posts_spec.rb

describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_response_schema("posts")
  end
end
```

You can even embed schemas inside other schemas!

First, declare the singular version of your schema.

```json
# spec/support/api/schemas/post.json

{
  "type": "object",
  "required": ["id", "title", "body"],
  "properties": {
    "id": { "type": "integer" },
    "title": { "type": "string" },
    "body": { "type": "string" }
  }
}
```

Then, when you declare your collection schema, embed the singular schema with
`ERB` and `schema_for`!

```json
# spec/support/api/schemas/posts.json

{
  "type": "object",
  "required": ["posts"],
  "properties": <%= schema_for("post") %>
}
```

## Configuration

By default, the schema directory is `spec/support/api/schemas`.

This can be configured via `Shoulda::Matchers::Json.schema_root`.


```ruby
# spec/support/shoulda-matchers-json.rb

Shoulda::Matchers::Json.schema_root = "docs/api/schemas"
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/shoulda-matchers-json/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
