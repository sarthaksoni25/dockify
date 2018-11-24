class AddFileToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :file, :string
  end
end
