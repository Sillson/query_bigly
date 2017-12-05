module QueryBigly  
  module Helpers
    def set_table_date(date)
      date.strftime('%Y%m%d')
    end

    def set_table_date_range(date)
      date.strftime('%Y%m*')
    end

    def build_table_hash(klass)
      klass.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
    end

    def format_schema_for_creation(hsh)
      hsh.map {|k,v| ["table.schema.#{v}","#{k}"]}
    end
  end
end