module JsonMatchers
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
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
