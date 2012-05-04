
class Vms::Inventory::Item < ActiveRecord::Base  
  self.table_name = "vms_inventory_items"
  
  has_many :item_instances, :class_name => "Vms::Inventory::ItemInstance"
  belongs_to :item_category, :class_name => "Vms::Inventory::ItemCategory"
end