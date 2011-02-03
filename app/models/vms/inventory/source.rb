
class Vms::Inventory::Source < ActiveRecord::Base  
  set_table_name "vms_inventory_sources"  
  
  has_many :inventories, :class_name => "Vms::Inventory"
end