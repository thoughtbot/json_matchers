if RSpec.respond_to?(:configure)
  RSpec.configure do |config|
    config.include JSON::Matchers
  end
end
