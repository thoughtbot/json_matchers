master
------

* BREAKING CHANGE: Rename the gem to `json_matchers`.

0.3.1
-----

* BREAKING CHANGE: Rename module to `JsonMatchers`. This resolves clashing with
  gems like `oj` / `oj_mimic_json` that take control of the standard library's
  `json` module. As a result, the file to require is now `json_matchers`,
  instead of `json/matchers`.

* No longer condone auto-loading RSpec. Add documentation around adding `require
  "json_matchers/rspec"` to consumers' `spec/spec_helper.rb`

0.3.0
-----

* Pass options from matcher to `JSON::Validator`

0.2.2
-----

* Includes validation failure message in RSpec output

0.2.1
-----

* Supports RSpec 2 syntax `failure_message_for_should` and
  `failure_message_for_should_not`
