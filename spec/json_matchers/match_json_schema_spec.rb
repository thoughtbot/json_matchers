describe JsonMatchers, "#match_json_schema" do

  let(:file_helper) { :json_for }
  let(:described_matcher) { :match_json_schema }

  it_behaves_like 'schema_matcher'

end
