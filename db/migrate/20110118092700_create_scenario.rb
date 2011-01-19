class CreateScenario < ActiveRecord::Migration
  def self.up
    create_table :vms_scenarios do |t|
      t.string :name
      t.integer :creator_id
      t.index :creator_id
      t.integer :state
    end
  end

  def self.down
    drop_table :vms_scenarios
  end
end
