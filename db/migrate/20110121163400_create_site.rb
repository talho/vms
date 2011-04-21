class CreateSite < ActiveRecord::Migration
  def self.up
    create_table :vms_sites do |t|
      t.string :name
      t.string :address
      t.string :lat
      t.string :lng
    end
    
    create_table :vms_scenario_site do |t|
      t.integer :site_id
      t.integer :scenario_id
      t.integer :status      
    end
    
    add_index :vms_scenario_site, :site_id
    add_index :vms_scenario_site, :scenario_id
  end

  def self.down
    remove_index :vms_scenario_site, :site_id
    remove_index :vms_scenario_site, :scenario_id
    
    drop_table :vms_scenario_site
    drop_table :vms_sites
  end
end
