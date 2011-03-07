class CreateStaff < ActiveRecord::Migration
  def self.up
    create_table :vms_staff do |t|
      t.integer :user_id
      t.index :user_id
      t.integer :scenario_site_id
      t.index :scenario_site_id
      t.index [:user_id, :scenario_site_id], :unique => true
      t.string :status
      t.index :status
    end
  end

  def self.down
    drop_table :vms_staff
  end
end
