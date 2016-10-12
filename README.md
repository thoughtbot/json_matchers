# JsonMatchers

Validate the JSON returned by your Rails JSON APIs

## Installation

Add this line to your application's Gemfile:

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

Inspired by [Validating JSON Schemas with an RSpec Matcher](http://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher)

First, include it in your `spec_helper`:

```ruby
# spec/spec_helper.rb

require "json_matchers/rspec"
```

Define your [JSON Schema](http://json-schema.org/example1.html) in the schema directory:

```json
# spec/support/api/schemas/posts.json

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

Then, validate `response` against your schema with `match_response_schema`

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

Alternatively, `match_response_schema` accepts a string:

```ruby
# spec/requests/posts_spec.rb

describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response.body).to match_json_schema("posts")
  end
end
```

### Passing options to the validator

The matcher accepts options, which it passes to the validator:

```ruby
# spec/requests/posts_spec.rb

describe "GET /posts" do
  it "returns Posts" do
    get posts_path, format: :json

    expect(response.status).to eq 200
    expect(response).to match_response_schema("posts", strict: true)
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

This can be configured via `JsonMatchers.schema_root`.


```ruby
# spec/support/json_matchers.rb

JsonMatchers.schema_root = "docs/api/schemas"
```

## Contributing

Please see [CONTRIBUTING].

`json_matchers` was inspired by [Validating JSON Schemas with an
RSpec Matcher][blog post] by Laila Winner.

`json_matchers` was written and is maintained by Sean Doyle.

Many improvements and bugfixes were contributed by the [open source community].

[blog post]: https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher
[CONTRIBUTING]: https://github.com/thoughtbot/json_matchers/blob/master/CONTRIBUTING.md
[open source community]: https://github.com/thoughtbot/json_matchers/graphs/contributors

## License

json_matchers is Copyright © 2015 Sean Doyle and thoughtbot.

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
