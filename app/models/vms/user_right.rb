class Vms::UserRight < ActiveRecord::Base  
  set_table_name "vms_user_rights"
  
  belongs_to :user
  belongs_to :scenario, :class_name => "Vms::Scenario"
  
  PERMISSIONS = {:reader => 1, :admin => 2, :owner => 3}
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("user_right") ? json["user_right"] : json).merge!( 
      {:name => user.display_name, :caption => "#{user.name} #{user.email}", :user_id => user.id, :title => user.title})
    json
  end
end