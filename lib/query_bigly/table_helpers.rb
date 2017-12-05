module QueryBigly  
  module TableHelpers

    def set_table_name(klass, table_date=nil)
      if table_date
        table_name = klass.table_name + '_' + table_date
      else
        table_name = klass.table_name
      end
    end

    def set_table_date(date)
      date.strftime('%Y%m%d')
    end

    def set_table_date_range(date)
      date.strftime('%Y%m*')
    end

    def build_model_schema(klass)
      hsh = klass.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
      format_schema_helper(hsh)
    end

    def format_schema_helper(hsh)
      hsh.map {|k,v| ["#{v}".to_sym,"#{k}"]}
    end
  end
end