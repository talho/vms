
class Vms::VolunteerRole < ActiveRecord::Base
  set_table_name :vms_volunteer_roles
  
  belongs_to :volunteer, :class_name => '::User'
  belongs_to :role, :class_name => '::Role'
  belongs_to :alert, :class_name => 'VmsExecutionAlert'
  
  def alert_type=(sType)
    p sType.to_s
    super(sType.to_s.classify.constantize.base_class.to_s)
  end
end