class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :vms_teams do |t|
      t.integer :audience_id
      t.index :audience_id
      t.integer :scenario_site_id
      t.index :scenario_site_id
    end
  end

  def self.down
    drop_table :vms_staff
  end
end
