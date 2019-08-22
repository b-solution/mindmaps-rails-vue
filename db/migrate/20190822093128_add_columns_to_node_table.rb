class AddColumnsToNodeTable < ActiveRecord::Migration[5.2]
  def change
    add_column :nodes, :left, :integer
    add_column :nodes, :top, :integer
  end
end
