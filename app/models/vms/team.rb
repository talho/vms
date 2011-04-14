
class Vms::Team < ActiveRecord::Base  
  set_table_name "vms_teams"
  
  belongs_to :audience, :autosave => true, :dependent => :destroy
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"
  
  def name
    audience.name
  end
  
  def name=(val)
    audience.name = val
  end
  
  def as_json(options = {})
    options[:methods].nil? ? options[:methods] = [:name] : options[:methods] << :name
    options[:methods].uniq!
    json = super(options)
    ( json.key?("team") ? json["team"] : json).merge!( 
      {:site => site.name, :site_id => site.id, :user_count => audience.users.count})
    json
  end
  
  def users
    audience.recipients
  end
end