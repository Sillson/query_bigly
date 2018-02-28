module QueryBigly  
  module FormatHelpers

    ## Table Helpers
    
    # Sets the name of a table / logic if needs to be partioned for ActiveRecord models
    def format_table_name(klass, table_date=nil)
      if table_date
        table_name = klass.table_name + '_' + table_date
      else
        table_name = klass.table_name
      end
    end

    # BigQuery's Table Date suffix structure
    def format_table_date(date)
      date.strftime('%Y%m%d')
    end

    # BigQuery's Table Date Range suffix structure
    def format_table_date_range(date)
      date.strftime('%Y%m*')
    end

    ## Schema Helpers

    # Builds a model schema and then formats it for QueryBigly::Client
    def format_model_schema(klass)
      hsh = klass.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
      format_schema_helper(hsh)
    end

    # formats the schema for QueryBigly::Client
    def format_schema_helper(hsh)
      hsh = map_data_types(hsh)
      hsh.map { |column_name,column_type| ["#{column_type}".to_sym,"#{column_name}"] }
    end

    ## Custom Field Helpers

    def format_custom_fields(custom_fields)
      custom_fields = use_any_aliases(custom_fields)
      reformat_custom_field_types_to_sym(custom_fields)
    end

    # Persist only the aliases in the custom fields after the record has been instansiated
    def use_any_aliases(custom_fields)
      custom_fields.map { |column_name,column_type| [column_name.gsub(/.*AS\s+/, ''), column_type] }.to_h
    end

    # Sidekiq turns the symbol values into strings, undo that
    def reformat_custom_field_types_to_sym(custom_fields)
      result = {}
        custom_fields.each_pair do |key, value|
          result[key] = if value.class == Hash
                          reformat_custom_field_types_to_sym(value)
                        else
                          value.to_sym
                        end
        end
      result
    end

    # Rails datatypes != BigQuery datatypes
    def map_data_types(hsh)
      hsh.each_with_object({}) { |(column_name, column_type), hash| hash[column_name] = map_value(column_type) }
    end

    # TODO: Possible find a way to keep an updatable 'constants' of this list 
    # and make this logic smarter
    def map_value(column_type)
      case column_type
      when :datetime then :timestamp
      when :json then :string
      else column_type
      end
    end

    # JSON data types is not supported. Ingest a record an transforms all JSON values to strings
    # It is recommended the User flattens the JSON by formatting custom fields
    def stringify_json_attributes(record)
      record.each_with_object({}) { |(key, value), hash| hash[key] = json_values_to_string(value) }
    end

    # Stringify a value with a class of Hash 
    def json_values_to_string(value)
      value.class == Hash ? value.to_s : value
    end
  end
end