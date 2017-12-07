require 'spec_helper'

RSpec.describe QueryBigly::TableHelpers do
  let(:extended_class)  { Class.new { extend QueryBigly::TableHelpers } }
  let(:including_class) { Class.new { include QueryBigly::TableHelpers } }
  let(:test_table_date) { DateTime.parse('2017-03-30') }
  let(:test_klass) { Dog }

  it "can set the table name" do
    expect(extended_class.set_table_name(Dog)).to eq('dogs')
  end

  it "can set the table name and partition by a date" do
    expect(extended_class.set_table_name(Dog, '20170330')).to eq('dogs_20170330')
  end

  it "can set a date to the proper BigQuery format" do
    expect(extended_class.set_table_date(test_table_date)).to eq('20170330')
    expect(including_class.new.set_table_date(test_table_date)).to eq('20170330')
  end

  it "can set a table date range to the proper BigQuery format" do
    expect(extended_class.set_table_date_range(test_table_date)).to eq('201703*')
    expect(including_class.new.set_table_date_range(test_table_date)).to eq('201703*')
  end

end
