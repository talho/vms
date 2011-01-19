
class User
  has_many :scenarios, :class_name => 'Vms::Scenario', :foreign_key => 'creator_id'
end

class Vms::Scenario < ActiveRecord::Base  
  set_table_name "vms_scenarios"
  
  belongs_to :creator, :class_name => 'User'
  
  STATES = {:template => 1, :unexecuted => 2, :executed => 3}
  
  validates_presence_of :name
end