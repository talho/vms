class CreateUserRights < ActiveRecord::Migration
  def self.up
    create_table :vms_user_rights do |t|
      t.integer :scenario_id
      t.integer :user_id
      t.integer :permission_level
    end
    
    add_index :vms_user_rights, :scenario_id
    add_index :vms_user_rights, :user_id
    
    execute("
      INSERT INTO vms_user_rights(scenario_id, user_id, permission_level)\
      SELECT id, creator_id, 3\
      FROM vms_scenarios\
    ")
    
    remove_index :vms_scenarios, :creator_id
    remove_column :vms_scenarios, :creator_id
  end

  def self.down
    add_column :vms_scenarios, :creator_id, :integer
    add_index :vms_scenarios, :creator_id
    
    Vms::Scenario.all.each do |scen|
      execute(%{\
        UPDATE vms_scenarios\
        SET creator_id = vms_user_rights.user_id\
        FROM vms_user_rights\
        WHERE vms_user_rights.scenario_id = #{scen.id}\
          AND vms_scenario.id = #{scen.id}\
      })
    end
    
    drop_table :vms_user_rights
  end
end
