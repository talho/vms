
class Vms::Inventory::ItemCollection < ActiveRecord::Base  
  set_table_name "vms_inventory_item_collections"  
  
  belongs_to :inventory, :class_name => "Vms::Inventory"
  belongs_to :user
  has_many :item_instances, :class_name => "Vms::Inventory::ItemInstance"
  
  STATUS = {:available => 1, :assigned => 2}
end