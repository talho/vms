
class Vms::Scenario < ActiveRecord::Base  
  set_table_name "vms_scenarios"
  
  belongs_to :creator, :class_name => 'User'
  
  STATES = {:template => 1, :unexecuted => 2, :executed => 3}
  
  validates_presence_of :name
end