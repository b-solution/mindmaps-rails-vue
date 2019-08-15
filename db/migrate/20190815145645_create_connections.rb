class CreateConnections < ActiveRecord::Migration[5.2]
  def change
    create_table :connections do |t|
      t.float :parent_x
      t.float :parent_y
      t.float :child_x
      t.float :child_y
      t.references :mindmap, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end
