class AddCheckedInToStaff < ActiveRecord::Migration
  def self.up
    add_column :vms_staff, :checked_in, :boolean
  end

  def self.down
    remove_column :vms_staff, :checked_in
  end
end
