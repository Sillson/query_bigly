module QueryBigly
  module StreamModel
    extend QueryBigly::TableHelpers

    def self.stream_model(klass, pk, custom_fields={}, partition_by=nil)
      # allow the user to overwrite the partition field...maybe add logic later to check if it's valid
      partition_by = 'created_at' || partition_by
      # format the record, use custom fields if desired...
      # example of custom_fields format:
      # { "id_client"=>:integer,
      #   "client_urn"=>:string,
      #   "id_budget"=>:integer,
      #   "name_budget"=>:string,
      #   "budget_urn"=>:string,
      #   "created_at"=>:datetime }
      record     = format_record(klass, pk, custom_fields.keys)
      # set the table date
      table_date = set_table_date(record[partition_by])
      # push to QueryBigly::Client to insert to the appropriate table
      QueryBigly::Client.new.stream_model(klass, record, custom_fields, table_date)
    end

    def self.set_model_attributes(klass)
      @table_name    = klass.table_name
      @column_schema = klass.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
    end

    def self.format_record(klass, pk, custom_fields)
     # allow user to pass in custom fields (unnest json/alias columns)
      custom_fields = klass.column_names if custom_fields.empty?
      custom_fields = custom_fields.join(', ')

      # record will need to have a primary key!
      record = klass.select(attributes).where("#{klass.primary_key} = ?", pk).as_json.first
    end

    def self.partioniable?(partition_field)
      if partition_field == :date || :datetime || :timestamp
        partition_field
      else
        nil
      end
    end
  end
end