class CreateWalkup < ActiveRecord::Migration
  def self.up
    create_table :vms_walkups do |t|
      t.integer :scenario_site_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :checked_in, :default => false
    end
    add_index :vms_walkups, :scenario_site_id
  end

  def self.down
    remove_index :vms_walkups, :scenario_site_id
    drop_table :vms_walkups
  end
end
