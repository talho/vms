class CreateStaff < ActiveRecord::Migration
  def self.up
    create_table :vms_staff do |t|
      t.integer :user_id
      t.integer :scenario_site_id
      t.string :status
    end
    
    add_index :vms_staff, :user_id
    add_index :vms_staff, :scenario_site_id
    add_index :vms_staff, [:user_id, :scenario_site_id], :unique => true
    add_index :vms_staff, :status
  end

  def self.down 
    remove_index :vms_staff, :user_id
    remove_index :vms_staff, :scenario_site_id
    remove_index :vms_staff, [:user_id, :scenario_site_id]
    remove_index :vms_staff, :status
    
    drop_table :vms_staff
  end
end
