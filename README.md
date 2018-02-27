# QueryBigly

A quick and dirty G5-Rails <> BigQuery integration. This gem is in beta -- and is also my first foray into gem building.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'query_bigly'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install query_bigly

## Usage

### Do These Things First

- Copy the environment variables out of `.env`, and include them in your application. Change all values as pertains to your project
- **THIS IS IMPORTANT**: create a dataset in your BigQuery project, and set `DEFAULT_DATASET` to that value. Make sure it's unique to your project, and don't overwrite or corrupt other datasets. Set your `BIGQUERY_KEYFILE_JSON` environment variable to the credentials gifted to you via devops, it should be surrounded in quotes as follows: '{type:"type", project_id: "project_id"}'.

### Basic BigQuery actions

The `QueryBigly::Client` class is an abstracted way to consistently interface with the `Google::Cloud::Bigquery` class from the `google-cloud-bigquery` gem.

- `QueryBigly::Client.new()` will instansiate a new client with your default attributes.
- `QueryBigly::Client.new(override_dataset, override_project_id)` will enable you to override the defaults set in environment variables

#### Querying

Run a Query
```
statement = SELECT * FROM dogs;
QueryBigly::Client.new.run_query(statement)
```

Run an Asynchronous Query
```
statement = SELECT * FROM dogs;
QueryBigly::Client.new.run_async_query(statement)
```
*PROTIP* - make sure to `squish` your statements to remove whitespace. 

#### Bulk Insertion

Currently this is a pretty ungraceful way to cram data into BigQuery. Be warned, this is a destructive action.

`QueryBigly::Client.new.bulk_insert_model(klass, data_as_an_array_of_json, table_name=nil, custom_fields={})`

This will dump the table of a given class into BigQuery. Be sure to properly set your `DEFAULT_DATASET` or override the default dataset upon creation of your `QueryBigly::Client.new(override_dataset)`


#### Streaming
Stream a Record
```
table_id = 'your_cool_table'
row_data = {'column_name'=>'your_cool_data', 'column_name_2'=>123}

QueryBigly::Client.new.stream_record_to_bigquery(table_id, row_data)
```

#### Table Creation

### Stream an ActiveRecord::Model

As it stands, this will be the starting point for streaming our models to BigQuery -- more to come on this. Create a job via sidekiq/resque that follow this pattern:

```
class PushRecordToBigQueryWorker
  include Sidekiq::Worker

  def perform(klass, pk, custom_fields={}, partition_by=nil)
    QueryBigly::StreamModel.stream_model(klass, pk, custom_fields, partition_by)
  end
end
```

I elected to _not_ include this job in the gem because of the various configurations of jobs that we have across our applications. It's up to you to build this piece of logic.

1. In your model, create an after_commit callback to push_your_model_to_bigquery
2. In that callback, instantiate the `PushRecordToBigQueryWorker` with the appropriate arguements

**Custom Fields:**
Some records are going to require custom fields, whether your purpose is to flatten a JSON column (JSON data types are NOT supported in BigQuery) or to leave out erroneous information. The custom_fields pattern will look something like the following:

```
# example from Interaction in CXM
def custom_fields
    {
      "id"=>:integer,
      "occurred_at"=>:datetime,
      "created_at"=>:datetime,
      "updated_at"=>:datetime,
      "person_location_id"=>:integer,
      "payload"=>:json,
      "lead_uid"=>:string,
      "source"=>:string,
      "marketing_source_urn"=>:string,
      "location_urn"=>:string,
      "client_urn"=>:string,
      "payload_type"=>:string,
      "full_name"=>:string,
      "location_name"=>:string,
      "payload->'type' AS nested_payload_type"=>:string,
      "payload->'ga_client_id' AS ga_client_id"=>:string,
      "payload->'system' AS user_system"=>:string,
      "payload->'category' AS category"=>:string,
      "payload->'normalized'->'customer'->'first_name' AS first_name"=>:string,
      "payload->'normalized'->'customer'->'last_name' AS last_name"=>:string,
      "payload->'normalized'->'customer'->'name' AS name"=>:string,
      "payload->'normalized'->'customer'->'telephone' AS telephone"=>:string,
      "payload->'normalized'->'customer'->'email' AS email"=>:string,
      "payload->'normalized'->'customer'->'existing_customer' AS existing_customer"=>:string,
      "payload->'normalized'->'customer'->'lead_type' AS lead_type"=>:string,
      "payload->'normalized'->'call'->'called_number' AS dialed_number"=>:string,
      "payload->'normalized'->'call'->'duration' AS call_duration"=>:string,
      "payload->'normalized'->'call'->'mp3_url' AS mp3_url"=>:string
    }
  end
```
**Partition By:**
Since asynchronous inserts are not supported in this version, partitioning our tables by a datetime column is mandatory. The default is `created_at`, but you can overwrite that with any given datetime/timestamp/date column. 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/g5search/query_bigly. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the QueryBigly project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/g5search/query_bigly/blob/master/CODE_OF_CONDUCT.md).
