require 'spec_helper'

RSpec.describe QueryBigly::Client do
  subject { QueryBigly::Client }
  let(:google_cloud_bigquery) { double }
  let(:test_dataset) { 'your_sweet_app' }
  
  before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(google_cloud_bigquery)
    allow(google_cloud_bigquery).to receive(:dataset).and_return(test_dataset)
  end

  describe "initialize client" do
    let(:new_client) { subject.new }
    let(:override_project_id) { 'override-project-id' }
    let(:override_keyfile) { 'new_keyfile' }
    let(:new_client_with_overrides) { subject.new(override_project_id, override_keyfile) }
    
    it 'can initialize' do
      expect(new_client).to be_a_kind_of(QueryBigly::Client)
    end

    it 'will set the defaults project_id' do
      expect(new_client.instance_variable_get(:@keyfile)).to eq('/path/to/key/json_key.json')
      expect(new_client.instance_variable_get(:@project_id)).to eq('test-google-project')
      expect(new_client.dataset).to eq(test_dataset)
    end

    it 'can override the defaults' do
      expect(new_client_with_overrides.instance_variable_get(:@keyfile)).to eq(override_keyfile)
      expect(new_client_with_overrides.instance_variable_get(:@project_id)).to eq(override_project_id)
    end
  end
end