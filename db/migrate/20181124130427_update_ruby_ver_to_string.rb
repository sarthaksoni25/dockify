class UpdateRubyVerToString < ActiveRecord::Migration[5.1]
  def change
    remove_column :images, :ruby_version
    add_column :images,:ruby_ver, :string
  end
end
