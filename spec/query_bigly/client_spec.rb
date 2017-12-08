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

  describe "run queries" do
    let(:statement) { 'SELECT * FROM dogs_20170330;' }
    let(:job) { double }
    let(:run_query) { subject.new.run_query(statement) }
    let(:run_async_query) { subject.new.run_async_query(statement) }

    before do
      allow(google_cloud_bigquery).to receive(:query).and_return(true)
      allow(google_cloud_bigquery).to receive(:query_job).and_return(job)
      allow(job).to receive(:wait_until_done!).and_return(true)
      allow(job).to receive(:failed?).and_return(true)
    end

    it 'should run a query' do
      expect(run_query).to be true
    end

    context 'run_async job fails' do
      it 'should run an asynchronous query' do
        expect(run_async_query).to eq("Asynchronous query has failed!")
      end
    end

    context 'run async job succeeds' do
      before do
        allow(job).to receive(:failed?).and_return(false)
        allow(job).to receive(:data).and_return(true)
      end

      it 'should run an asynchronous query' do
        expect(run_async_query).to be true
      end
    end
  end
end