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
      t.index :site_id
      t.integer :scenario_id
      t.index :scenario_id
      t.integer :status      
    end
  end

  def self.down
    drop_table :vms_scenario_site
    drop_table :vms_sites
  end
end
