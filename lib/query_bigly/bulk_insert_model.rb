module QueryBigly
  module BulkInsertModel
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

    def self.bulk_insert_model(klass, dataset, remote_table_name=nil, custom_fields={})
      data = format_record(klass, custom_fields.keys)
      custom_fields = format_custom_fields(custom_fields) if !custom_fields.empty?
      QueryBigly::Client.new(dataset).bulk_insert_model(klass, data, remote_table_name, custom_fields)
    end

    def self.format_record(klass, custom_field_keys)
      # allow user to pass in custom fields (unnest json/alias columns)
      custom_field_keys = klass.column_names if custom_field_keys.empty?
      query_fields = custom_field_keys.join(', ')
      record = klass.select(query_fields).all.as_json

      # JSON data types not currently supported
      record = stringify_json_attributes(record)
    end
  end
end