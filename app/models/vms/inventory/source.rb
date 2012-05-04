
class Vms::Inventory::Source < ActiveRecord::Base  
  self.table_name = "vms_inventory_sources"  
  
  has_many :inventories, :class_name => "Vms::Inventory"
end