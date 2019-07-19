master
======

0.11.1
======

* Follow first-level symlinks in the document store. [#99]

[#99]: https://github.com/thoughtbot/json_matchers/pull/99

0.11.0
======

* Expand references of DocuemntStore schemas ([#93], [3b66b4d])

[#93]: https://github.com/thoughtbot/json_matchers/pull/93
[3b66b4d]: https://github.com/thoughtbot/json_matchers/commit/3b66b4ddf369ec09b50cfe39c614266b34c7f3fe

0.10.0
======

* *BREAKING CHANGE* Implement the validation with the `json_schema` gem instead
  of `json-schema`. [#31]
* *BREAKING CHANGE* - remove support for configuring validation options.

[#31]: https://github.com/thoughtbot/json_matchers/pull/31

0.9.0
=====

* Deprecate support for configuring validation options.

0.8.0
=====

* Add `assert_json_matches_schema` and `refute_json_matches_schema` for
  use in `minitest` test suites [#66]

[#66]: https://github.com/thoughtbot/json_matchers/pull/66

0.7.3
=====

* Alias `match_response_schema` to `match_json_schema`. These matches can
  validate any JSON, whether it's from a request body, a response body, a Hash,
  or a String. [#68]

[#68]: https://github.com/thoughtbot/json_matchers/pull/68

0.7.2
=====

* Accept Array instances as arguments to `match_response_schema` [#60]

[#60]: https://github.com/thoughtbot/json_matchers/issues/60

0.7.1
=====

* Accept Hash instances as arguments to `match_response_schema` [#58], [#59]

[#58]: https://github.com/thoughtbot/json_matchers/pull/58
[#59]: https://github.com/thoughtbot/json_matchers/pull/59

0.7.0
=====

* Default `record_errors: true` [#52]
* Add support for configuring `record_errors` [#51]

[#52]: https://github.com/thoughtbot/json_matchers/pull/52
[#51]: https://github.com/thoughtbot/json_matchers/pull/51

0.6.3
=====

* Fix error message for string responses. [#49]

[#49]: https://github.com/thoughtbot/json_matchers/pull/49

0.6.2
=====

* Remove dependency on Rails. [#47]

[#47]: https://github.com/thoughtbot/json_matchers/pull/47

0.6.1
=====

* Configure default options for all matchers. [#46]
* Use `JSON.pretty_generate` to format error messages. [#44]

[#46]: https://github.com/thoughtbot/json_matchers/pull/46
[#44]: https://github.com/thoughtbot/json_matchers/pull/44

0.6.0
=====

* Accept a JSON string along with a `response`.

[#43]: https://github.com/thoughtbot/json_matchers/pull/43

0.5.1
=====

* Update `json-schema` dependency to `~> 2.6.0`. [#37]

[#37]: https://github.com/thoughtbot/json_matchers/pull/37

0.5.0
=====

Breaking Changes
----------------

* No longer default to `strict: true`.

0.4.0
=====

Breaking Changes
----------------

* Rename the gem to `json_matchers`.

0.3.1
=====

* No longer condone auto-loading RSpec. Add documentation around adding `require
  "json_matchers/rspec"` to consumers' `spec/spec_helper.rb`

Breaking Changes
----------------

* Rename module to `JsonMatchers`. This resolves clashing with
  gems like `oj` / `oj_mimic_json` that take control of the standard library's
  `json` module. As a result, the file to require is now `json_matchers`,
  instead of `json/matchers`.

0.3.0
=====

* Pass options from matcher to `JSON::Validator`

0.2.2
=====

* Includes validation failure message in RSpec output

0.2.1
=====

* Supports RSpec 2 syntax `failure_message_for_should` and
  `failure_message_for_should_not`

0.2.0
=====

* RSpec failure messages include both the body of the response, and the body of
  the JSON Schema file

0.1.0
=====

Breaking Changes
----------------

* Remove `schema_for` in favor of using `$ref`. To learn more about `$ref`,
  check out [Understanding JSON Schema Structuring](http://spacetelescope.github.io/understanding-json-schema/structuring.html)

0.0.1
=====

Features
--------

* Validate your Rails response JSON with `match_response_schema`
