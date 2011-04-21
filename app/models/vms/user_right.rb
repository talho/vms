class Vms::UserRight < ActiveRecord::Base  
  set_table_name "vms_user_rights"
  
  belongs_to :user
  belongs_to :scenario, :class_name => "Vms::Scenario"
  
  PERMISSIONS = {:reader => 1, :admin => 2, :owner => 3}
end