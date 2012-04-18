class RecreateVmsAlerts < ActiveRecord::Migration
  def self.up
    DropMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
    DropMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
    DropMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
    DropMTIFor(VmsAlert)
    CreateMTIFor(VmsAlert)
    CreateMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
    CreateMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
    CreateMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
  end

  def self.down
  end
end
