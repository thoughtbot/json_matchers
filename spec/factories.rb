FactoryBot.define do
  FakeResponse = Struct.new(:body)

  factory :response, class: FakeResponse do
    skip_create

    initialize_with do
      body = attributes[:body]
      payload = attributes.except(:body)

      FakeResponse.new(body || payload.to_json)
    end
  end
end
