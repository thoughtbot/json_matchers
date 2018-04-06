FakeSchema = Struct.new(:name, :json) do
  def to_h
    json
  end

  def to_s
    name
  end
end
