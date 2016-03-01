class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :number
      t.string :text
      t.references :book, index: true
    end
  end
end
