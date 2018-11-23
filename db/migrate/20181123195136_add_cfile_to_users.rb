class AddCfileToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :composefile, :string
  end
end
