class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :vms_roles_scenario_sites do |t|
      t.integer :role_id
      t.index :role_id
      t.integer :scenario_site_id
      t.index :scenario_site_id
      t.integer :count
    end
  end

  def self.down
    drop_table :vms_roles_scenario_sites
  end
end
