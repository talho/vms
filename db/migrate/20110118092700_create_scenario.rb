class CreateScenario < ActiveRecord::Migration
  def self.up
    create_table :vms_scenarios do |t|
      t.string :name
      t.integer :creator_id
      t.integer :state
    end
    
    add_index :vms_scenarios, :creator_id
  end

  def self.down
    remove_index :vms_scenarios, :creator_id
    drop_table :vms_scenarios
  end
end
