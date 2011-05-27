class CreateVmsStatusAlertMti < ActiveRecord::Migration
  def self.up
    CreateMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
  end

  def self.down
    DropMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
  end
end
