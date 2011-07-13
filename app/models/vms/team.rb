class Vms::Team < ActiveRecord::Base  
  set_table_name "vms_teams"

  belongs_to :audience, :autosave => true, :dependent => :destroy
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"

  def name
    audience.name
  end                                       

  def name=(val)
    audience.update_attribute("name",val)
  end

  def as_json(options = {})
    json = super(options)
    ( json.key?("team") ? json["team"] : json).merge!(
      {:site => site.name, :site_id => site.id, :user_count => audience.users.count, :all_checked_in => all_checked_in?, :name => name})
  end

  def all_checked_in?
    member_ids = audience.users.map(&:id)
    scenario_site.staff.find_all_by_user_id_and_checked_in(member_ids, true).count == member_ids.count
  end

  def to_s
     audience.recipients.count.to_s + ' member team: ' + Vms::ScenarioSite.find(scenario_site_id).to_s
  end

  def to_s
     Audience.find(audience_id).recipients.count.to_s + ' member team: ' + Vms::ScenarioSite.find(scenario_site_id).to_s
  end
end