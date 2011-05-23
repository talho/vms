class CreateVolunteerRoles < ActiveRecord::Migration
  def self.up
    create_table :vms_volunteer_roles do |t|
      t.integer :alert_id
      t.integer :volunteer_id
      t.integer :role_id
    end
    
    add_index :vms_volunteer_roles, :alert_id
    add_index :vms_volunteer_roles, :volunteer_id
    add_index :vms_volunteer_roles, :role_id
    #add_index :vms_volunteer_roles, [:alert_id, :volunteer_id, :role_id], :unique => true, :name => 'index_vms_volunteer_roles_on_unique_index'
  end

  def self.down
    remove_index :vms_volunteer_roles, :alert_id
    remove_index :vms_volunteer_roles, :volunteer_id
    remove_index :vms_volunteer_roles, :role_id
    #remove_index :vms_volunteer_roles, 'unique_index'
    
    drop_table :vms_volunteer_roles
  end
end
