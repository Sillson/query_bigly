require 'spec_helper'

RSpec.describe QueryBigly::StreamModel do
  let(:subject) { QueryBigly::StreamModel }
  let(:test_klass) { Dog }
  let(:test_date) { DateTime.parse('2017-03-30') }
  let(:custom_fields) { {'id'=>:integer,
                         'name AS dog_name'=>:string,
                         'last_office_visit'=>:datetime,
                         'age AS fake_json_field'=> :json
                        } }
  let(:record) { Dog.create(id: 1, owner_id: 1, is_good_boy: true, age: 7, last_office_visit: test_date) }

  describe "format_record" do
    
    before do
      record
    end
    
    context "a class is passed to be queried" do
      it "returns a hash of a record" do
        expect(subject.format_record(Dog,1,{})).to be_a(Hash)
      end
    end

    context "custom fields are used for querying"
      let(:format_record_method) { subject.format_record(Dog,1,custom_fields.keys) }
      it "can accept custom fields" do
        expect(format_record_method).to be_a(Hash)
      end

      it "returns the appropriate number of fields" do
        expect(format_record_method.count).to eq(custom_fields.count)
      end
  end
end