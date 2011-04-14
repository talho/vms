
class Vms::Inventory::ItemInstance < ActiveRecord::Base  
  set_table_name "vms_inventory_item_instances"
  
  belongs_to :item_collection, :class_name => "Vms::Inventory::ItemCollection"
  belongs_to :item, :class_name => "Vms::Inventory::Item", :include => :item_category
  
  validates_presence_of :item
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("item_instance") ? json["item_instance"] : json).merge!( {:name => item.name, :category_id => item.item_category_id, :category => (item.item_category ? item.item_category.name : nil), 
                                                                          :consumable => item.consumable, :inventory_id => item_collection.inventory_id })
    json
  end
end