class AddAdminToScenarioSite < ActiveRecord::Migration
  def self.up
    add_column :vms_scenario_site, :site_admin_id, :integer
  end

  def self.down
    remove_column :vms_scenario_site, :site_admin_id
  end
end
