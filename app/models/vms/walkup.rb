
class Vms::Walkup < ActiveRecord::Base
  set_table_name "vms_walkups"

  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"

  def to_s
    first_name + ' ' + last_name
  end
end