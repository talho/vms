
class VmsStatusAlert < VmsAlert
  acts_as_MTI
  set_table_name 'view_status_vms_alerts'
  
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsStatusAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
   
  def self.default_alert(options = {})
    options[:title] ||= "VMS Status Alert"
    options[:message] ||= "The status of the scenario has been modified."
    options[:created_at] = Time.zone.now
    VmsStatusAlert.new options
  end
  
  def formatted_message(user)
    staff = self.scenario.staff.find_by_user_id(user) unless self.scenario.nil?
    staff.nil? ? self.message : "The status of the scenario has been modified. You are currently assigned to site #{staff.site.name} at #{staff.site.address}."
  end
  
  def to_xml
    options = {:Messages => {}, :Recipients => {}, :IVRTree => {} }
    
    staff = self.scenario.staff.find_all_by_user_id(recipients(true).map(&:id))
        
    options[:Messages][:override] = Proc.new do |messages|
      messages.Message(:name => 'title') {|msg| msg.Value self.title}
      messages.Message(:name => 'msg_custom') {|msg| msg.Value self.message || "The status of the scenario has been modified."}
      messages.Message(:name => 'msg_body_1') {|msg| msg.Value " You are currently assigned to site "}
      messages.Message(:name => 'site_name') {|msg| msg.Value "site_name"}
      messages.Message(:name => 'msg_body_2') {|msg| msg.Value " at "}
      messages.Message(:name => 'site_address') {|msg| msg.Value "site_address"}
      messages.Message(:name => 'msg_body_3') {|msg| msg.Value "."}
    end
    
    options[:Recipients][:override] = Proc.new do |rcpts|
      staff.each do |s|
        rcpts.Recipient(:id => s.user.id, :givenName => s.user.first_name, :surname => s.user.last_name, :display_name => s.user.display_name) do |rcpt|
          (s.user.devices.find_all_by_type(self.alert_device_types.map(&:device))).each do |device|
            rcpt.Device(:id => device.id, :device_type =>  device.class.display_name) do |d|
              d.URN device.URN
              d.Message(:name => 'site_name') {|msg| msg.Value s.site.name}
              d.Message(:name => 'site_address') {|msg| msg.Value s.site.address}
            end
          end
        end
      end
    end
  
    options[:IVRTree][:override] = Proc.new do |ivrtree|
      ivrtree.IVR(:name => 'message_ivr') do |ivr|
        ivr.RootNode(:operation => 'start') do |root_node|
          root_node.ContextNode do |ctxt|
            ctxt.operation 'put'
            ctxt.response(:ref => 'msg_custom')
            ctxt.response(:ref => 'msg_body_1')
            ctxt.response(:ref => 'site_name')
            ctxt.response(:ref => 'msg_body_2')
            ctxt.response(:ref => 'site_address')
            ctxt.response(:ref => 'msg_body_3')
          end
        end
      end
    end

    super(options);
  end
end