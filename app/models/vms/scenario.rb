
class Vms::Scenario < ActiveRecord::Base  
  set_table_name "vms_scenarios"
  
  belongs_to :creator, :class_name => 'User'
  has_many :site_instances, :class_name => "Vms::ScenarioSite" do
    def for_site(id)
      find_by_site_id(id)
    end
    def for_site_by_name(name)
      for_site(Vms::Site.find_by_name(name))
    end
  end
  has_many :sites, :through => :site_instances
  
  has_many :inventories, :through => :site_instances
  has_many :staff, :through => :site_instances
  
  STATES = {:template => 1, :unexecuted => 2, :executed => 3}
  
  validates_presence_of :name
end