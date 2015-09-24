# JSON::Matchers

Validate the JSON returned by your Rails JSON APIs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json-matchers', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-matchers

## Usage

Inspired by [Validating JSON Schemas with an RSpec Matcher](http://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher)

First, include it in your `spec_helper`:

```ruby
# spec/spec_helper.rb

require "json/matchers"
```

Define your [JSON Schema](http://json-schema.org/example1.html) in the schema directory:

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

### Passing options to the validator

The matcher accepts options, which it'll pass to the validator:

```ruby
# spec/requests/posts_spec.rb

describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_response_schema("posts", strict: false)
  end
end
```

A list of available options can be found [here][options]

[options]: https://github.com/ruby-json-schema/json-schema/blob/2.2.4/lib/json-schema/validator.rb#L160-L162

### Embedding other Schemas

To DRY up your schema definitions, use JSON schema's `$ref`.

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

Then, when you declare your collection schema, reference your singular schemas.

```json
# spec/support/api/schemas/posts.json

{
  "type": "object",
  "required": ["posts"],
  "properties": {
    "posts": {
      "type": "array",
      "items": { "$ref": "post.json" }
    }
  }
}
```

NOTE: `$ref` resolves paths relative to the schema in question.

In this case `"post.json"` will be resolved relative to
`"spec/support/api/schemas"`.

To learn more about `$ref`, check out [Understanding JSON Schema Structuring](http://spacetelescope.github.io/understanding-json-schema/structuring.html)

## Configuration

By default, the schema directory is `spec/support/api/schemas`.

This can be configured via `JSON::Matchers.schema_root`.


```ruby
# spec/support/json-matchers.rb

JSON::Matchers.schema_root = "docs/api/schemas"
```

## Contributing

1. Fork it ( https://github.com/thoughtbot/json-matchers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
