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

  before_destroy :remove_site_admin_status

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.scenario_site.to_s} - #{x.to_s}" }, :app => 'vms' }

  def as_json(options = {})
    json = super(options)
    ( json.key?("staff_instance") ? json["staff_instance"] : (json.key?('staff') ? json['staff'] : json) ).merge!( 
      {:site => scenario_site.site.name, :site_id => scenario_site.site.id, :user => user.display_name, :user_id => user.id, :site_admin => scenario_site.site_admin_id == user.id })
  end
  
  def self.users_as_staff_json(users)
    users.map { |u| {:user => u.display_name, :user_id => u.id, :status => 'assigned', :source => u[:source], :id => u[:staff_id] } }
  end

  def self.send_removed_message(users, scenario)
    if(scenario.executing? && users.count > 0)
      alert = VmsAlert.new :scenario => scenario, :author => scenario.users.owner, :audiences => [Audience.new( :users => users)], :title => "You have been unassigned",
              :message => "You have been unassigned from your volunteer site and not reassigned to a different. You will be notified if you are reassigned later."
      alert.save
    end
  end
  
  def self.send_added_message(staff, site_instance)
    if(site_instance.scenario.executing? && staff.count > 0)
      alert = VmsAlert.new :scenario => site_instance.scenario, :author => site_instance.scenario.users.owner, :audiences => [Audience.new( :users => staff.map(&:user))], :title => "You have been assigned to a site",
              :message => "You have been assigned to #{site_instance.site.name} at #{site_instance.site.address}. Please make your way there now, if you are not already, and check-in when you arrive."
      alert.save
    end
  end

  def self.send_updated_message(staff)
    #for now, we aren't really updating anything about the staff so we're not going to send a message.
  end

  def to_s
    user.to_s
  end

  protected

  def remove_site_admin_status
    scenario_site.update_attribute(:site_admin_id, nil) if user_id == scenario_site.site_admin_id
  end

end