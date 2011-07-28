
class Vms::Inventory::ItemCollection < ActiveRecord::Base  
  set_table_name "vms_inventory_item_collections"  
  
  belongs_to :inventory, :class_name => "Vms::Inventory"
  belongs_to :user
  has_many :item_instances, :class_name => "Vms::Inventory::ItemInstance" do
    def find_or_build_by_item(item)
      find_by_item_id(item) || build(:item => item)
    end
  end
  
  STATUS = {:available => 1, :assigned => 2}
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s }, :app => 'vms' }
  
  def to_s
    (!self.inventory.nil? ? self.inventory.name : '') + (!self.user.nil? ? " - #{self.user.to_s}" : '')
  end
end