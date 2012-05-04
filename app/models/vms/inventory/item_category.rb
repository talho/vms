
class Vms::Inventory::ItemCategory < ActiveRecord::Base  
  self.table_name = "vms_inventory_item_categories" 
  
  has_many :items, :class_name => "Vms::Inventory::Item" 
end