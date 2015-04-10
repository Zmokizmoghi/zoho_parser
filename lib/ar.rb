ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'tasks'
    create_table :tasks do |table|
      table.column :external_id,      :string
      table.column :resolver,         :string
      table.column :accepted,         :boolean
      table.column :paid,         :boolean
      table.column :budget,           :string

    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'orders'
    create_table :orders do |table|
      table.column :comment,      :string
      table.column :team,         :string
      table.column :i_budget,     :string
      table.column :a_budget,     :string
      table.column :invoice,      :string
      table.column :description,  :string
      table.column :completed,    :boolean
      table.column :paid,    :boolean
      table.column :number,       :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'invoices'
    create_table :invoices do |table|
      table.column :client,      :string
      table.column :external_id, :string
      table.column :paid, :boolean
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'sub_orders'
    create_table :sub_orders do |table|
      table.column :main_order,  :integer
      table.column :sub_order, :integer
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'issue_orders'
    create_table :issue_orders do |table|
      table.column :issue_id,  :integer
      table.column :order_number, :integer
      table.column :budget, :string

    end
  end
end

module DB
  class Task < ActiveRecord::Base
    self.table_name = 'tasks'
  end

  class Order < ActiveRecord::Base
    self.table_name = 'orders'
  end

  class Invoice < ActiveRecord::Base
    self.table_name = 'invoices'
  end

  class SubOrder < ActiveRecord::Base
    self.table_name = 'sub_orders'
  end

  class IssueOrder < ActiveRecord::Base
    self.table_name = 'issue_orders'
  end
end
