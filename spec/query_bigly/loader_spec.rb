require 'spec_helper'

RSpec.describe QueryBigly::Loader do
  let(:extended_class)  { Class.new { extend QueryBigly::Loader } }
  let(:custom_fields) { {'id'=>:integer,
                         'name AS dog_name'=>:string,
                         'last_office_visit'=>:datetime,
                         'age AS fake_json_field'=> :json
                        } }
  let(:model_double) { double }

  before do
    allow(QueryBigly::BulkInsertModel).to receive(:bulk_insert_model).and_return(model_double)
  end

  describe "bulk_insert_to_big_query" do
    let(:subject) { extended_class.bulk_insert_to_bigquery }
    
    it "will call the BulkInsertModel" do
      expect(QueryBigly::BulkInsertModel).to receive(:bulk_insert_model)
      subject
    end

    it "will pass in defaults of klass, nil, nil, and an empty hash" do
      expect(QueryBigly::BulkInsertModel).to receive(:bulk_insert_model).with(extended_class,nil,nil,{})
      subject
    end
  end
end