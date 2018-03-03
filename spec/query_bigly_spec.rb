require 'spec_helper'

RSpec.describe QueryBigly do
  subject { QueryBigly }

  context "environment variable is set" do
    it "can access the project_id" do
      expect(QueryBigly.project_id).to eq('test-google-project')
    end

    it "can access the default_dataset" do
      expect(QueryBigly.default_dataset).to eq('test-database')
    end
  end
end
