require 'spec_helper'

RSpec.describe QueryBigly::FormatHelpers do
  let(:extended_class)  { Class.new { extend QueryBigly::FormatHelpers } }
  let(:including_class) { Class.new { include QueryBigly::FormatHelpers } }
  let(:test_table_date) { DateTime.parse('2017-03-30') }
  let(:test_klass) { Dog }
  let(:custom_fields) { {'id'=>:integer,
                         'name AS dog_name'=>:string,
                         'last_office_visit'=>:datetime,
                         'age AS fake_json_field'=> :json
                        } }
  let(:record) { Dog.create(id: 1, owner_id: 1, is_good_boy: true, age: 7, last_office_visit: test_table_date) }

  describe "include/extend" do
    it "module can be included or extended" do
      expect(extended_class.format_table_name(Dog)).to  eq(including_class.new.format_table_name(Dog))
    end
  end

  describe "format table name" do                      
    it "can format the table name" do
      expect(extended_class.format_table_name(Dog)).to eq('dogs')
    end

    it "can format the table name and partition by a date" do
      expect(extended_class.format_table_name(Dog, '20170330')).to eq('dogs_20170330')
    end
  end

  describe "format table date" do
    it "can format a date to the proper BigQuery format" do
      expect(extended_class.format_table_date(test_table_date)).to eq('20170330')
      expect(including_class.new.format_table_date(test_table_date)).to eq('20170330')
    end

    it "can format a table date range to the proper BigQuery format" do
      expect(extended_class.format_table_date_range(test_table_date)).to eq('201703*')
      expect(including_class.new.format_table_date_range(test_table_date)).to eq('201703*')
    end
  end

  describe "format_model_schema" do
    let(:subject) { extended_class.format_model_schema(test_klass) }
    it "can build an array of column types and names from an ActiveRecord model" do
      expect(subject).to be_a(Array)
    end

    it "the array will include the same number of columns as the ActiveRecord model" do
      expect(subject.count).to eq(Dog.column_names.count)
    end
  end

  describe "format_schema_helper" do
    let(:subject) { extended_class.format_schema_helper(custom_fields) }
    
    it 'can build an array of column types and names from custom field input' do
      expect(subject).to be_a(Array)
    end

    it "the array will include the same number of columns as the custom_fields input" do
      expect(subject.count).to eq(custom_fields.count)
    end
  end

  describe "use_any_aliases" do
    let(:subject) { extended_class.use_any_aliases(custom_fields) }

    it "will alter the custom fields' hash column names to use aliases instead of ActiveRecord column names" do
      expect(subject.include?('age')).to be(false)
    end

    it "will persist the column names that are not aliases" do
      expect(subject.include?('last_office_visit')).to be(true)
    end
  end

  describe "map_data_types" do
    let(:subject) { extended_class.format_schema_helper(custom_fields) }
    let(:find_json_field) { subject.find { |item| item.include?(:json) } }
    let(:find_datetime_field) { subject.find { |item| item.include?(:datetime) } }
    let(:json_field_has_changed) { subject.find { |item| item.include?('age AS fake_json_field') } }
    let(:datetime_field_has_changed) { subject.find { |item| item.include?('last_office_visit') } }
    
    it 'will remove json data types' do
      expect(find_json_field).to be_nil
      expect(custom_fields.has_value?(:json)).to be true
    end

    it 'will convert json data types to strings' do
      expect(json_field_has_changed[0]).to eq(:string)
    end

    it 'will remove datetime data types' do
      expect(find_datetime_field).to be_nil
      expect(custom_fields.has_value?(:datetime)).to be true
    end

    it 'will convert datetime data types to timestamps' do
      expect(datetime_field_has_changed[0]).to eq(:timestamp)
    end
  end
end
