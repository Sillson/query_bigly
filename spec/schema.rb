ActiveRecord::Schema.define do
  self.verbose = false

  create_table :dogs, :force => true do |t|
    t.string   :name
    t.integer  :owner_id
    t.boolean  :is_good_boy?
    t.integer  :age
    t.datetime :last_office_visit
    t.timestamps
  end

end