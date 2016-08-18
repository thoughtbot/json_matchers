describe JsonMatchers, "#match_response_schema" do

  let(:file_helper) { :response_for }
  let(:described_matcher) { :match_response_schema }

  it_behaves_like 'schema_matcher'

end
