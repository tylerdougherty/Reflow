class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :archiveID
      t.string :description
      t.string :downloadStatus
    end
  end
end
