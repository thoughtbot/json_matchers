# JsonMatchers

Validate the JSON returned by your Rails JSON APIs

## Installation

Add this line to your application's `Gemfile`:

```ruby
group :test do
  gem "json_matchers"
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_matchers

## Usage

Inspired by [Validating JSON Schemas with an RSpec Matcher][original-blog-post].

[original-blog-post]: (https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher)

First, configure it in your test suite's helper file:

### Configure

#### RSpec

`spec/spec_helper.rb`

```ruby
require "json_matchers/rspec"

JsonMatchers.schema_root = "spec/support/api/schemas"
```

#### Minitest

`test/test_helper.rb`

```ruby
require "minitest/autorun"
require "json_matchers/minitest/assertions"

JsonMatchers.schema_root = "test/support/api/schemas"

Minitest::Test.include(JsonMatchers::Minitest::Assertions)
```

### Declare

Declare your [JSON Schema](https://json-schema.org/example1.html) in the schema
directory.

`spec/support/api/schemas/location.json` or
`test/support/api/schemas/location.json`:

Define your [JSON Schema](https://json-schema.org/example1.html) in the schema
directory.

```json
{
  "id": "https://json-schema.org/geo",
  "$schema": "https://json-schema.org/draft-06/schema#",
  "description": "A geographical coordinate",
  "type": "object",
  "properties": {
    "latitude": {
      "type": "number"
    },
    "longitude": {
      "type": "number"
    }
  }
}
```

### Validate

#### RSpec

Validate a JSON response, a Hash, or a String against a JSON Schema with
`match_json_schema`:

`spec/requests/locations_spec.rb`

```ruby
describe "GET /locations" do
  it "returns Locations" do
    get locations_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_json_schema("locations")
  end
end
```

#### Minitest

Validate a JSON response, a Hash, or a String against a JSON Schema with
`assert_matches_json_schema`:

`test/integration/locations_test.rb`

```ruby
def test_GET_posts_returns_Locations
  get locations_path, format: :json

  assert_equal response.status, 200
  assert_matches_json_schema response, "locations"
end
```

### Embedding other Schemas

To re-use other schema definitions, include `$ref` keys that refer to their
definitions.

First, declare the singular version of your schema.

`spec/support/api/schemas/user.json`:

```json
{
  "id": "file:/user.json#",
  "type": "object",
  "required": ["id"],
  "properties": {
    "id": { "type": "integer" },
    "name": { "type": "string" },
    "address": { "type": "string" },
  },
}
```

Then, when you declare your collection schema, reference your singular schemas.

`spec/support/api/schemas/users/index.json`:

```json
{
  "id": "file:/users/index.json#",
  "type": "object",
  "definitions": {
    "users": {
      "description": "A collection of users",
      "example": [{ "id": "1" }],
      "type": "array",
      "items": {
        "$ref": "file:/user.json#"
      },
    },
  },
  "required": ["users"],
  "properties": {
    "users": {
      "$ref": "#/definitions/users"
    }
  },
}
```

NOTE: `$ref` resolves paths relative to the schema in question.

In this case `"user.json"` and `"users/index.json"` are resolved relative to
`"spec/support/api/schemas"` or `"test/support/api/schemas"`.

To learn more about `$ref`, check out
[Understanding JSON Schema Structuring][$ref].

[$ref]: https://spacetelescope.github.io/understanding-json-schema/structuring.html

### Declaring a schema in a Subdirectory

Nesting a schema within a subdirectory is also supported:

`spec/support/api/schemas/api/v1/location.json`:


```json
{
  "id": "https://json-schema.org/geo",
  "$schema": "https://json-schema.org/draft-06/schema#",
  "description": "A geographical coordinate",
  "type": "object",
  "properties": {
    "latitude": {
      "type": "number"
    },
    "longitude": {
      "type": "number"
    }
  }
}
```

`spec/requests/api/v1/locations_spec.rb`:

```ruby
describe "GET api/v1/locations" do
  it "returns Locations" do
    get locations_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_json_schema("api/v1/location")
  end
end
```

## Configuration

By default, the schema directory is `spec/support/api/schemas`.

This can be configured via `JsonMatchers.schema_root`.

```ruby
# spec/support/json_matchers.rb

JsonMatchers.schema_root = "docs/api/schemas"
```

## Upgrading from `0.9.x`

Calls to `match_json_schema` and `match_response_schema` no longer accept
options, and `JsonMatchers.configure` has been removed.

## Contributing

Please see [CONTRIBUTING].

`json_matchers` was inspired by [Validating JSON Schemas with an
RSpec Matcher][blog post] by Laila Winner.

`json_matchers` is maintained by Sean Doyle.

Many improvements and bugfixes were contributed by the [open source community].

[blog post]: https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher
[CONTRIBUTING]: https://github.com/thoughtbot/json_matchers/blob/master/CONTRIBUTING.md
[open source community]: https://github.com/thoughtbot/json_matchers/graphs/contributors

## License

`json_matchers` is Copyright © 2018 thoughtbot.

It is free software, and may be redistributed under the terms specified in the
[LICENSE] file.

[LICENSE]: LICENSE.txt

## About thoughtbot

![thoughtbot](https://thoughtbot.com/logo.png)

`json_matchers` is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community].
We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com?utm_source=github
