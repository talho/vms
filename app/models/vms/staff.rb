
class Vms::Staff < ActiveRecord::Base  
  set_table_name "vms_staff"
  
  belongs_to :user
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("staff_instance") ? json["staff_instance"] : json).merge!( 
      {:site => site.name, :site_id => site.id, :user => user.display_name, :user_id => user.id })
    json
  end
end