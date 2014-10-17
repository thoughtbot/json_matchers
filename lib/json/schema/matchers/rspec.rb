if RSpec.respond_to?(:configure)
  RSpec.configure do |config|
    config.include JSON::Schema::Matchers
  end
end
