module QueryBigly
  module Loader
    def bulk_insert_to_bigquery(klass=self, dataset=nil, remote_table_name=nil, custom_fields={})
      QueryBigly::BulkInsertModel.bulk_insert_model(klass, dataset, remote_table_name, custom_fields)
    end
  end
end