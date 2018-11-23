class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :name
      t.boolean :postgres
      t.boolean :nginx
      t.boolean :redis
      t.boolean :ruby_version

      t.timestamps
    end
  end
end
