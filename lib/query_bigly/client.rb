module QueryBigly
  class Client
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

    def set_table_date(date)
      date.strftime('%Y%m%d')
    end

    def set_table_date_range(date)
      date.strftime('%Y%m*')
    end
  end
end