module JsonMatchers
  class Payload
    def initialize(payload)
      @payload = extract_json_string(payload)
    end

    def as_json
      JSON.parse(payload)
    end

    def to_s
      payload
    end

    private

    attr_reader :payload

    def extract_json_string(payload)
      if payload.respond_to?(:body)
        payload.body
      elsif payload.is_a?(Array) || payload.is_a?(Hash)
        payload.to_json
      else
        payload.to_s
      end
    end
  end
end
