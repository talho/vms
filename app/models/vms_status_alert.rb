
class VmsStatusAlert < VmsAlert
  acts_as_MTI
  set_table_name 'view_status_vms_alerts'
  
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsStatusAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
   
  def self.default_alert(options = {})
    options[:title] ||= "VMS Status Alert"
    options[:message] ||= "The status of the scenario has been modified. You are currently assigned to site {site_name} at {site_address}"
    options[:created_at] = Time.zone.now
    VmsStatusAlert.new options
  end
  
  def to_xml
    options = {:Messages => {}, :Recipients => {}, :Behavior => {:Delivery => {:Providers => {} } }, :IVRTree => {} }
    
    message_names = []
    staff = self.scenario.staff.find_all_by_user_id(recipients.map(&:id))
    
    options[:Messages][:supplement] = Proc.new do |messages|
      staff.each do |s|
        message_names << message_name = "user_#{s.user_id}"
        messages.Message(:name => message_name, :lang => "en/us", :encoding => "utf8", :content_type => "text/plain") do |message|
          message.Value self.message.gsub(/\{[^}]*\}/) { |m| {'{site_name}' => s.site.name, '{site_address}' => s.site.address}[m] }
        end
      end
    end
    
    options[:Recipients][:override] = Proc.new do |rcpts|
      recipients.each do |recipient|
        rcpts.Recipient(:id => recipient.id, :givenName => recipient.first_name, :surname => recipient.last_name, :display_name => recipient.display_name) do |rcpt|
          (recipient.devices.find_all_by_type(self.alert_device_types.map(&:device))).each do |device|
            rcpt.Device(:id => device.id, :device_type =>  device.class.display_name) do |d|
              d.URN device.URN
              d.Message(:name => 'message', :ref => "user_#{recipient.id}")
            end
          end
        end
      end
    end
    
    options[:Behavior][:Delivery][:Providers][:supplement] = Proc.new do |providers|
      message_names.each do |message|
        role_name = build_role_name(roles)
        (self.alert_device_types.map{|device| device.device_type.display_name} || Service::SWN::Message::SUPPORTED_DEVICES.keys).each do |device|
          providers.Provider(:name => "swn", :device => device, :ivr => 'acknowledge_alert') do |provider|
            provider.Messages do |messages|
              messages.ProviderMessage(:name => 'message', :ref => message)
            end
          end
        end
      end
    end

    super(options);
  end
end