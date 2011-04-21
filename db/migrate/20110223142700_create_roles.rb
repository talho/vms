class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :vms_roles_scenario_sites do |t|
      t.integer :role_id
      t.integer :scenario_site_id
      t.integer :count
    end
    
    add_index :vms_roles_scenario_sites, :role_id
    add_index :vms_roles_scenario_sites, :scenario_site_id
  end

  def self.down
    remove_index :vms_roles_scenario_sites, :role_id
    remove_index :vms_roles_scenario_sites, :scenario_site_id
    drop_table :vms_roles_scenario_sites
  end
end
