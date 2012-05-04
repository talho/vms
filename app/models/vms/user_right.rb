class Vms::UserRight < ActiveRecord::Base  
  self.table_name = "vms_user_rights"
  
  belongs_to :user, :class_name => "::User"
  belongs_to :scenario, :class_name => "Vms::Scenario"
  
  PERMISSIONS = {:reader => 1, :admin => 2, :owner => 3}
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.to_s}" }, :app => 'vms' }
  
  def as_json(options = {})
    json = super(options)
    ( json.key?("user_right") ? json["user_right"] : json).merge!( 
      {:name => user.display_name, :caption => "#{user.name} #{user.email}", :email => user.email, :user_id => user.id, :title => user.title})
    json
  end

  def to_s
    'Level ' + permission_level.to_s + ': ' + User.find(user_id).to_s + ': ' + Vms::Scenario.find(scenario_id).to_s 
  end
end