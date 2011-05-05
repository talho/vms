class AddStaffState < ActiveRecord::Migration
  def self.up
    change_table :vms_staff do |t|
      t.string :source, :default => 'manual'
    end
    
  end

  def self.down 
    remove_column :vms_staff, :source
  end
end
