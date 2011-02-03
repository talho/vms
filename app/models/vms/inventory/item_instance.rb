
class Vms::Inventory::ItemInstance < ActiveRecord::Base  
  set_table_name "vms_inventory_item_instances"
  
  belongs_to :item_collection, :class_name => "Vms::Inventory::ItemCollection"
  belongs_to :item, :class_name => "Vms::Inventory::Item"
end