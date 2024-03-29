class Vms::Team < ActiveRecord::Base  
  self.table_name = "vms_teams"

  belongs_to :audience, :autosave => true, :dependent => :destroy
  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"

  after_create :make_staff

  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.name} - #{x.to_s}" }, :app => 'vms' }
  
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
     self.audience.recipients.count.to_s + ' member team: ' + self.scenario_site.to_s
  end

  def make_staff
    unless scenario_site.nil?
      audience.recipients.each do | user |
        staff = scenario_site.staff.find_or_create_by_user_id_and_scenario_site_id( user.id, scenario_site.id)
        staff.update_attributes({:source => 'team'})
      end
    end
  end
end