module QueryBigly
  class Client
    extend QueryBigly::Helpers
    attr_accessor :bigquery, :dataset

    def initialize(project_id=nil, keyfile=nil, dataset=nil)
      @project_id = project_id || QueryBigly.project_id
      @keyfile = keyfile || QueryBigly.keyfile

      @bigquery = Google::Cloud::Bigquery.new(
        project: @project_id,
        keyfile: @keyfile
        )
      @dataset = @bigquery.dataset dataset
    end

    def stream_record_to_bigquery(klass, record, custom_fields, table_date=nil)
      table = create_partitioned_table_if_not_exists(klass, custom_fields, table_date)
      stream_to_bigquery(table.table_id, record)
    end

    def stream_to_bigquery(table_id, row_data)
      table    = @dataset.table table_id
      response = table.insert row_data
      if response.success?
        puts "Inserted rows successfully"
      else
        puts "Failed to insert #{response.error_rows.count} rows"
      end
    end

    def run_async_query(statement)
      job = @bigquery.query_job(statement)
      job.wait_until_done!
      if job.failed?
        "Asynchronous query has failed!"
      else
        job.data
      end
    end

    def run_query(statement)
      @bigquery.query(statement)
    end

    def insert_async(table, data)
      inserter = table.insert_async do |response|
        log_insert "inserted #{response.insert_count} rows" \
          "with #{response.error_count} errors"
      end
      inserter.insert data
      inserter.stop.wait!
    end

    def delete_table(table_name)
      table = @dataset.table table_name
      begin
        table.delete
      rescue NoMethodError => e
        "#{table_name} does not exists..."
      end
    end

    def create_table(klass, custom_fields={}, table_date=nil)
      if table_date
        table_name = klass.table_name + "_" + table_date
      else
        table_name = klass.table_name
      end

      if custom_fields.empty?
        table = @dataset.create_table "#{table_name}" do |table|
          build_table_hash(klass).map {|k,v| ["table.schema.#{v}","#{k}"]}.each do |type_name|
            eval(type_name[0]) "#{type_name[1]}"
          end
        end
      else
        table = @dataset.create_table "#{table_name}" do |table|
          custom_fields.map {|k,v| ["table.schema.#{v}","#{k}"]}.each do |type_name|
            eval(type_name[0]) "#{type_name[1]}"
          end
        end
      end
    end

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

    def create_partitioned_table_if_not_exists(klass, custom_fields, table_date)
      table = @dataset.table "#{klass.table_name}_#{table_date}"
      table.nil? ? create_new_table(table_hash, custom_fields, table_date) : table
    end
  end
end