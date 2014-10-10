require "shoulda/matchers/json"

Dir["./spec/support/*"].each { |file| require file }

RSpec.configure do |config|
  config.include Shoulda::Matchers::Json
  config.expect_with :rspec do |expectations|

    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
