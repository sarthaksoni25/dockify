class UpdateFieldsToString < ActiveRecord::Migration[5.1]
  def change
    remove_column :images, :postgres
    add_column :images,:postgres, :string

    remove_column :images, :redis
    add_column :images,:redis, :string

    add_column :images, :mysql, :string
  end
end
