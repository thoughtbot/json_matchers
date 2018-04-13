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

[original-blog-post]: (http://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher)

First, configure it in your test suite's helper file:

### Configure

#### RSpec

`spec/spec_helper.rb`

```ruby
require "json_matchers/rspec"

JsonMatchers.schema_root = "/spec/support/api/schemas"
```

#### Minitest

`test/test_helper.rb`

```ruby
require "minitest/autorun"
require "json_matchers/minitest/assertions"

JsonMatchers.schema_root = "/test/support/api/schemas"

Minitest::Test.send(:include, JsonMatchers::Minitest::Assertions)
```

### Declare

Declare your [JSON Schema](http://json-schema.org/example1.html) in the schema
directory.

`spec/support/api/schemas/posts.json` or `test/support/api/schemas/posts.json`:

```json
{
  "type": "object",
  "required": ["posts"],
  "properties": {
    "posts": {
      "type": "array",
      "items":{
        "required": ["id", "title", "body"],
        "properties": {
          "id": { "type": "integer" },
          "title": { "type": "string" },
          "body": { "type": "string" }
        }
      }
    }
  }
}
```

### Validate

#### RSpec

Validate a JSON response, a Hash, or a String against a JSON Schema with
`match_json_schema`:

`spec/requests/posts_spec.rb`

```ruby
describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_json_schema("posts")
  end
end
```

#### Minitest

Validate a JSON response, a Hash, or a String against a JSON Schema with
`assert_matches_json_schema`:

`test/integration/posts_test.rb`

```ruby
def test_GET_posts_returns_Posts
  get posts_path, format: :json

  assert_equal response.status, 200
  assert_matches_json_schema response, "posts"
end
```

### DEPRECATED: Passing options to the validator

The matcher accepts options, which it passes to the validator:

`spec/requests/posts_spec.rb`

```ruby
describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_json_schema("posts", strict: true)
  end
end
```

A list of available options can be found [here][options].

[options]: https://github.com/ruby-json-schema/json-schema/blob/2.2.4/lib/json-schema/validator.rb#L160-L162

### DEPRECATED: Global matcher options

To configure the default options passed to *all* matchers, call
`JsonMatchers.configure`.

`spec/support/json_matchers.rb`:

```rb
JsonMatchers.configure do |config|
  config.options[:strict] = true
end
```

A list of available options can be found [here][options].

### DEPRECATED: Default matcher options

* `record_errors: true` - *NOTE* `json_matchers` will always set
  `record_errors: true`. This cannot be overridden.

### Embedding other Schemas

To DRY up your schema definitions, use JSON schema's `$ref`.

First, declare the singular version of your schema.

`spec/support/api/schemas/post.json`:

```json
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

`spec/support/api/schemas/posts.json`:

```json
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

## Upgrading from `0.9.x`

After `json_matchers@0.9.x`, calls to `match_json_schema` and
`match_response_schema` no longer accept options, and `JsonMatchers.configure`
will been removed.

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
