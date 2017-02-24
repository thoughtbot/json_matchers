module ConfigurationHelpers
  def with_options(options)
    original_options = JsonMatchers.configuration.options.dup

    JsonMatchers.configure do |config|
      config.options.merge!(options)
    end

    yield

    JsonMatchers.configure do |config|
      config.options.clear
      config.options.merge!(original_options)
    end
  end
end

RSpec.configure do |config|
  config.include ConfigurationHelpers
end
