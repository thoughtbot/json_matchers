module JsonMatchers
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    warn <<-WARN
DEPRECATION: `JsonMatchers.configure`
  After `json_matchers@0.9.x`, JsonMatchers.configure will be removed.

  See https://github.com/thoughtbot/json_matchers/pull/31 for more information.

WARN

    yield(configuration)
  end

  class Configuration
    def initialize
      @options = {}
    end

    def options
      @options.merge!(record_errors: true)
    end
  end
end
