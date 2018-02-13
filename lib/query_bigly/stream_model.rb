module QueryBigly
  module StreamModel
    extend QueryBigly::FormatHelpers

    # example of custom_fields format:
    # { 
    #   "id_client"=>:integer,
    #   "client_urn"=>:string,
    #   "id_budget"=>:integer,
    #   "name_budget AS alias_name_here"=>:string,
    #   "budget_urn AS alias_name_here"=>:string,
    #   "created_at"=>:datetime 
    # }

    def self.stream_model(klass, pk, custom_fields={}, partition_by=nil)
      # allow the user to overwrite the partition field...maybe add logic later to check if it's valid
      # if the model is being streamed, we will want to partition it
      partition_by = 'created_at' if partition_by.nil?

      # Add a created_at to partition by if it's not included in the custom fields (and they're present)
      unless custom_fields.empty?
        custom_fields['created_at'] = :timestamp if !custom_fields.include?(partition_by)
      end

      # format the record, use custom fields if desired...
      record = format_record(klass, pk, custom_fields.keys)

      # format the table date
      table_date = format_table_date(record[partition_by])

      # If custom_fields, persist aliases as reformat strings to symbols from sidekiq
      custom_fields = format_custom_fields(custom_fields) if !custom_fields.empty?
      
      # push to QueryBigly::Client to insert to the appropriate table
      QueryBigly::Client.new.stream_model(klass, record, custom_fields, table_date)
    end

    def self.format_record(klass, pk, custom_field_keys)
      # allow user to pass in custom fields (unnest json/alias columns)
      custom_field_keys = klass.column_names if custom_field_keys.empty?
      query_fields = custom_field_keys.join(', ')

      # record will need to have a primary key!
      record = klass.select(query_fields).where("#{klass.primary_key} = ?", pk).as_json.first

      # JSON data types not currently supported
      record = stringify_json_attributes(record)
    end
  end
end