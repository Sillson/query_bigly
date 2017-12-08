module QueryBigly
  class Client
    include QueryBigly::FormatHelpers
    attr_accessor :bigquery, :dataset

    def initialize(project_id=nil, keyfile=nil, dataset=nil)
      @project_id = project_id || QueryBigly.project_id
      @keyfile = keyfile || QueryBigly.keyfile
      dataset = dataset || QueryBigly.default_dataset

      @bigquery = Google::Cloud::Bigquery.new(
        project: @project_id,
        keyfile: @keyfile
        )
      @dataset = @bigquery.dataset dataset
    end

    # Run a standard query -- same as a basic query with the UI
    def run_query(statement)
      @bigquery.query(statement)
    end

    # Kick of an async_query -- same as running a query job in the UI
    def run_async_query(statement)
      job = @bigquery.query_job(statement)
      job.wait_until_done!
      if job.failed?
        "Asynchronous query has failed!"
      else
        job.data
      end
    end

    ####################################################
    ## REQUIRES google-cloud-bigquery ~> 0.29 or greater
    ####################################################
    # Insert an array of json rows to a BigQuery table
    # def insert_async(table, data)
    #   inserter = table.insert_async do |response|
    #     log_insert "inserted #{response.insert_count} rows" \
    #       "with #{response.error_count} errors"
    #   end
    #   inserter.insert data
    #   inserter.stop.wait!
    # end

    # Streams an ActiveRecord model record to BigQuery
    def stream_model(klass, record, custom_fields={}, table_date=nil)
      binding.pry
      table = create_table_if_not_exists(klass, custom_fields, table_date)
      stream_record_to_bigquery(table.table_id, record)
    end

    # Streams a single record to BigQuery
    def stream_record_to_bigquery(table_id, row_data)
      table    = @dataset.table table_id
      response = table.insert row_data
      if response.success?
        puts "Inserted rows successfully"
      else
        puts "Failed to insert #{response.error_rows.count} rows"
      end
    end

    # Creates a BigQuery table if one does not exists for an ActiveRecord model record
    def create_table_if_not_exists(klass, custom_fields={}, table_date=nil)
      table_name = format_table_name(klass, table_date)
      table = @dataset.table table_name
      table.nil? ? create_table(table_name, klass, custom_fields) : table
    end

    # Creates a BigQuery table
    def create_table(table_name, klass=nil, custom_fields={})
      schema_array = create_schema_array(klass, custom_fields)
      table = @dataset.create_table "#{table_name}" do |table|
        schema_array.each do |type_name|
          table.schema.send(type_name[0], type_name[1])
        end
      end
    end

    # Creates the schema
    def create_schema_array(klass=nil, custom_fields={})
      if !custom_fields.empty?
        schema_array = format_schema_helper(custom_fields)
      elsif klass.nil? && custom_fields.empty?
        raise "No schema can be generated"
      else
         schema_array = format_model_schema(klass)
      end
    end

    # Takes a BigQuery SQL statement and table name to generate a table based off a query
    def create_table_from_query(statement, destination_table_name)
      delete_table(destination_table_name)
      destination_table = @dataset.create_table destination_table_name
      job = @bigquery.query_job(statement, table: destination_table, write: 'truncate', create: 'needed')
      job.wait_until_done!
      if job.failed?
        "Creating table from query has failed!"
      else
        job.data
      end
    end

    # Deletes a table in BigQuery
    def delete_table(table_name)
      table = @dataset.table table_name
      begin
        table.delete
      rescue NoMethodError => e
        "#{table_name} does not exists..."
      end
    end
  end
end