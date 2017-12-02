module QueryBigly
  module MapModel

    def self.included(base)
      base.extend(ClassMethods)
    end
      
    module ClassMethods
      def model_name
        puts self.name
        puts self.table_name
        puts self.column_names
      end
    end
  end
end