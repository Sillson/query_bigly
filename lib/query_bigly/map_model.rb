module QueryBigly
  module MapModel

    def self.stream_model_to_bigquery(model_name, table_name, column_schema, partition_by)
      partition = partitionable?(partition_by)
    end

    def partioniable?(partition_field)
      partition_field = :date || :datetime || :timestamp
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
      
    module ClassMethods
      
      def stream_model_to_bigquery(partition_by=nil)
        @bigquery_model_name    = self.name
        @bigquery_table_name    = self.table_name
        @bigquery_column_schema = self.columns_hash.map { |column_name,column| [column_name, column.type] }.to_h
        QueryBigly::MapModel.stream_model_to_bigquery(model_name, table_name, column_schema, partition_by)
      end
    end
  end
end