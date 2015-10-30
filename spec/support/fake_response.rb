FakeResponse = Struct.new(:body) do
  def to_h
    JSON.parse(body)
  end

  def to_json(*)
    body
  end
end
