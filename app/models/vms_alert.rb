
class VmsAlert < Alert
  # set_table_name 'alerts'
  # default_scope :conditions => {:alert_type => 'VmsAlert'}  
  # before_create :set_alert_type
  acts_as_MTI
  before_create :create_email_alert_device_type
  
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
  belongs_to :scenario, :class_name => "Vms::Scenario"
  
  def to_s
    title || ''
  end
  
  def self.default_alert
    title = "VMS Status Alert"
    message = "This alert is intended to update the user of a status change in the VMS system"
    VmsAlert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end
  
  def to_xml(options = {})
    unless options[:IVRTree]
      options[:IVRTree] = {}
      options[:IVRTree][:override] = Proc.new do |ivrtree|
        ivrtree.IVR(:name => 'message_ivr') do |ivr|
          ivr.RootNode(:operation => 'start') do |root_node|
            root_node.ContextNode do |ctxt|
              ctxt.operation 'put'
              ctxt.response(:ref => 'message')
            end
          end
        end
      end
    end
    
    unless options[:Behavior]
      options.merge!({:Behavior => {:Delivery => {:Providers => {} } } })
      options[:Behavior][:Delivery][:Providers][:override] = Proc.new do |providers|
        (self.alert_device_types.map{|device| device.device_type.display_name} || Service::TALHO::Message::SUPPORTED_DEVICES.keys).each do |device|
          providers.Provider(:name => "talho", :device => device, :ivr => 'message_ivr')
        end
      end
    end
    
    super(options)
  end
  
  private
  def set_alert_type
    debugger
    self[:alert_type] = "VmsAlert"
  end
  
  def create_email_alert_device_type
    alert_device_types << AlertDeviceType.new(:alert_id => self.id, :device => "Device::EmailDevice") unless alert_device_types.map(&:device).include?("Device::EmailDevice")
  end
end