class CreateVmsAlerts < ActiveRecord::Migration
  def self.up
    create_table :vms_alerts do |t|
      t.integer :alert_id
      t.integer :scenario_id
    end
    
    add_index :vms_alerts, :alert_id
    add_index :vms_alerts, :scenario_id
    
    CreateMTIFor(VmsAlert)
    CreateMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
  end

  def self.down
    remove_index :vms_alerts, :alert_id
    remove_index :vms_alerts, :scenario_id
    
    DropMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
    DropMTIFor(VmsAlert)
    drop_table :vms_alerts
  end
end
