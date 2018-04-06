require "json_matchers/rspec"

Dir["./spec/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include FileHelpers

  config.around do |example|
    ensure_fixtures("spec", "fixtures", "schemas") do
      example.run
    end
  end
end
