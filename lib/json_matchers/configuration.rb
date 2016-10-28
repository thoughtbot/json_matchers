module JsonMatchers
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_reader :options

    def initialize
      @options = {}
    end
  end
end
