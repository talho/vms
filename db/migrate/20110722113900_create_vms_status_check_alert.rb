class CreateVmsStatusCheckAlert < ActiveRecord::Migration
  def self.up
    CreateMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
  end

  def self.down
    DropMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
  end
end
