# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json/matchers/version"

Gem::Specification.new do |spec|
  spec.name          = "json-matchers"
  spec.version       = JSON::Matchers::VERSION
  spec.authors       = ["Sean Doyle"]
  spec.email         = ["seandoyle@thoughtbot.com"]
  spec.summary       = %q{Validate your Rails JSON API's JSON}
  spec.description   = %q{Validate your Rails JSON API's JSON}
  spec.homepage      = "https://github.com/seanpdoyle/json-matchers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("json-schema", ">= 1.2.1")
  spec.add_dependency("activesupport", '>= 3.0.0')

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", ">= 2.0"
end
