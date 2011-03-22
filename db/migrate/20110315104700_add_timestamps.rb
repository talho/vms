class AddTimestamps < ActiveRecord::Migration
  def self.up
    add_timestamps :vms_scenarios
    add_timestamps :vms_inventories
    add_timestamps :vms_inventory_item_categories
    add_timestamps :vms_inventory_item_collections
    add_timestamps :vms_inventory_item_instances
    add_timestamps :vms_inventory_items
    add_timestamps :vms_inventory_sources
    add_timestamps :vms_roles_scenario_sites
    add_timestamps :vms_scenario_site
    add_timestamps :vms_sites
    add_timestamps :vms_staff
  end

  def self.down    
    remove_timestamps :vms_scenarios
    remove_timestamps :vms_inventories
    remove_timestamps :vms_inventory_item_categories
    remove_timestamps :vms_inventory_item_collections
    remove_timestamps :vms_inventory_item_instances
    remove_timestamps :vms_inventory_items
    remove_timestamps :vms_inventory_sources
    remove_timestamps :vms_roles_scenario_sites
    remove_timestamps :vms_scenario_site
    remove_timestamps :vms_sites
    remove_timestamps :vms_staff
  end
end
