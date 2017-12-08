require "bundler/setup"
require "dotenv/load"
require "date"
require "active_record"
require "pry"
require "query_bigly"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/models.rb'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # stub any of these
  config.before(:each) do
    # let(:google_cloud_bigquery) { double }
    # allow(Google::Cloud::Bigquery).to receive(:new).and_return( google_cloud_bigquery )
    # allow(google_cloud_bigquery).to receive(:dataset).and_return( 'foo' )
  end

  # Keep that database clean
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
