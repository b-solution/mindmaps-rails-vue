class CreateNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :nodes do |t|
      t.string :title
      t.boolean :root
      t.references :mindmap, index: true, foreign_key: true
      t.timestamps
    end
  end
end
