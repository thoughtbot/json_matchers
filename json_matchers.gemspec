# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json_matchers/version"

Gem::Specification.new do |spec|
  spec.name          = "json_matchers"
  spec.version       = JsonMatchers::VERSION
  spec.authors       = ["Sean Doyle"]
  spec.email         = ["sean.p.doyle24@gmail.com"]
  spec.summary       = %q{Validate your Rails JSON API's JSON}
  spec.description   = %q{Validate your Rails JSON API's JSON}
  spec.homepage      = "https://github.com/thoughtbot/json_matchers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("json_schema")

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 2.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "factory_bot", ">= 4.8"
  spec.add_development_dependency "activesupport"
end
