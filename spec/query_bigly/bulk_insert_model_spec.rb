require 'spec_helper'

RSpec.describe QueryBigly::BulkInsertModel do
  let(:subject) { QueryBigly::BulkInsertModel }
  let(:test_klass) { Dog }
  let(:test_date) { DateTime.parse('2017-03-30') }
  let(:custom_fields) { {'id'=>:integer,
                         'name AS dog_name'=>:string,
                         'last_office_visit'=>:datetime,
                         'age AS fake_json_field'=> :json
                        } }
  let(:record_1) { Dog.create(id: 1, owner_id: 1, is_good_boy: true, age: 7, last_office_visit: test_date) }
  let(:record_2) { Dog.create(id: 2, owner_id: 2, is_good_boy: true, age: 5, last_office_visit: test_date) }
  let(:query_bigly_client) { double }

  before do
    record_1
    record_2
    allow(QueryBigly::Client).to receive(:new).and_return(query_bigly_client)
    allow(query_bigly_client).to receive(:bulk_insert_model).and_return(true)
  end

  describe 'bulk_insert_model' do
    context 'an ActiveRecord model is passed with defaults' do
      let(:test_case) { subject.bulk_insert_model(test_klass) }

      it 'will call to format the record' do
        expect(subject).to receive(:format_records)
        test_case
      end

      it 'wont call to format_custom_fields' do
        expect(subject).to_not receive(:format_custom_fields)
        test_case
      end

      it 'will attempt to create a new client instance' do
        expect(QueryBigly::Client).to receive(:new)
        test_case
      end
    end

    context 'an ActiveRecord model is passed with args' do
      let(:test_case) { subject.bulk_insert_model(test_klass, 'test_dataset', 'tabley', custom_fields) }

      it 'will call to format the record' do
        expect(subject).to receive(:format_records).with(test_klass, custom_fields.keys)
        test_case
      end

      it 'wont call to format_custom_fields' do
        expect(subject).to receive(:format_custom_fields).with(custom_fields)
        test_case
      end

      it 'will attempt to create a new client instance' do
        expect(QueryBigly::Client).to receive(:new).with('test_dataset')
        test_case
      end
    end

    describe 'format_records' do
      context 'an ActiveRecord model is passed with defaults' do
        let(:test_case) { subject.format_records(test_klass, []) }
        let(:default_columns) { test_klass.column_names.join(', ')}

      end

      context 'an ActiveRecord model is passed with args' do
      end
    end
  end

  describe "format_records" do
  end
end