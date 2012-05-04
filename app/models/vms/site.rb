
class Vms::Site < ActiveRecord::Base  
  self.table_name = "vms_sites"
  
  has_many :scenario_instances, :class_name => "Vms::ScenarioSite", :dependent => :destroy
  has_many :scenarios, :through => :scenario_instances
    
  validates_presence_of :name

  def to_s
    name
  end
end