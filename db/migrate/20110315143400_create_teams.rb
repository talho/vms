class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :vms_teams do |t|
      t.integer :audience_id
      t.index :audience_id
      t.integer :scenario_site_id
      t.index :scenario_site_id
    end
    
    add_index :vms_teams, :audience_id
    add_index :vms_teams, :scenario_site_id
  end

  def self.down
    remove_index :vms_teams, :audience_id
    remove_index :vms_teams, :scenario_site_id
    
    drop_table :vms_staff
  end
end
