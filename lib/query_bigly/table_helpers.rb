module QueryBigly  
  module TableHelpers

    # Sets the name of a table / logic if needs to be partioned for ActiveRecord models
    def set_table_name(klass, table_date=nil)
      if table_date
        table_name = klass.table_name + '_' + table_date
      else
        table_name = klass.table_name
      end
    end

    # BigQuery's Table Date suffix structure
    def set_table_date(date)
      date.strftime('%Y%m%d')
    end

    # BigQuery's Table Date Range suffix structure
    def set_table_date_range(date)
      date.strftime('%Y%m*')
    end

    # Builds a model schema and then formats it for QueryBigly::Client
    def build_model_schema(klass)
      hsh = klass.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
      format_schema_helper(hsh)
    end

    # formats the schema for QueryBigly::Client
    def format_schema_helper(hsh)
      hsh.map { |k,v| ["#{v}".to_sym,"#{k}"] }
    end

    # Rails datatypes != BigQuery datatypes
    def map_data_types(hsh)
      hsh.each_with_object({}) { |(key, value), hash| hash[key] = map_value(value) }
    end

    # TODO: Possible find a way to keep an updatable 'constants' of this list 
    # and make this logic smarter
    def map_value(value)
      if value == :datetime 
        :timestamp
      elsif value == :json
        :string
      else
        value
      end
    end

    # JSON data types is not supported. Ingest a record an transforms all JSON values to strings
    # It is recommended the User flattens the JSON by formatting custom fields
    def stringify_json_attributes(record)
      record.each_with_object({}) { |(key, value), hash| hash[key] = json_values_to_string(value) }
    end

    def json_values_to_string(value)
      value.class == Hash ? value.to_s : value
    end
  end
end