
class Vms::Inventory::ItemInstance < ActiveRecord::Base  
  self.table_name = "vms_inventory_item_instances"
  
  belongs_to :item_collection, :class_name => "Vms::Inventory::ItemCollection"
  belongs_to :item, :class_name => "Vms::Inventory::Item", :include => :item_category
  
  validates_presence_of :item
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.item_collection.to_s} - #{x.item.name}" }, :app => 'vms' }
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("item_instance") ? json["item_instance"] : json).merge!( {:name => item.name, :category_id => item.item_category_id, :category => (item.item_category ? item.item_category.name : nil), 
                                                                          :consumable => item.consumable, :inventory_id => item_collection.inventory_id })
    json
  end
end