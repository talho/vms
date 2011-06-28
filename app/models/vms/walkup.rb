
class Vms::Walkup < ActiveRecord::Base
  set_table_name "vms_walkups"

  belongs_to :scenario_site, :class_name => "Vms::ScenarioSite"
  has_one :site, :through => :scenario_site, :class_name => "Vms::Site"

  def as_json(options = {})
    json = super(options)
    ( json.key?("walkup") ? json["walkup"] : json).merge!( :user => "#{json['first_name']} #{json['last_name']}", :source => "walkup", :site => site.name, :site_id => site.id )
  end

  def to_s
    first_name + ' ' + last_name
  end
end