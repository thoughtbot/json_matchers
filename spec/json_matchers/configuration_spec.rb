describe JsonMatchers, ".configure" do
  it "ignores :record_errors configuration" do
    with_options(record_errors: false) do
      configured_options = JsonMatchers.configuration.options

      expect(configured_options).to include(record_errors: true)
    end
  end
end
