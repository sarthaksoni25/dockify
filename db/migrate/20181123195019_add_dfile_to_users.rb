class AddDfileToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :dockerfile, :string
    remove_column :users,:file
  end
end
