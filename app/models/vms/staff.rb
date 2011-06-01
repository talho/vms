# user_id          | integer                     |
# scenario_site_id | integer                     |
# status           | character varying(255)      |
# checked_in       | boolean                     | default false
# created_at       | timestamp without time zone |
# updated_at       | timestamp without time zone |

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
  
  def self.users_as_staff_json(users)
    users.map { |u| {:user => u.display_name, :user_id => u.id, :satus => 'assigned', :source => u[:source], :id => u[:staff_id] } }
  end

  def to_s
   user.to_s 
  end
end