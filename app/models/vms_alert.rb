
class VmsAlert < Alert
  # set_table_name 'alerts'
  # default_scope :conditions => {:alert_type => 'VmsAlert'}  
  # before_create :set_alert_type
  acts_as_MTI
  before_create :create_email_alert_device_type
  
  has_many :recipients, :class_name => "User", :finder_sql => proc{"SELECT users.* FROM users, targets, targets_users WHERE targets.item_type='VmsAlert' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id"}
  belongs_to :scenario, :class_name => "Vms::Scenario"
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s }, :app => Proc.new {|x| x.app} }
  
  def app
    'vms'
  end
  
  def to_s
    "#{scenario ? scenario.name : 'No scenario'} - #{title}"
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
  
  def formatted_message(user = nil)
    self.message
  end
  
  protected
  def create_email_alert_device_type
    alert_device_types << AlertDeviceType.new(:alert_id => self.id, :device => "Device::EmailDevice") unless alert_device_types.map(&:device).include?("Device::EmailDevice")
    alert_device_types << AlertDeviceType.new(:alert_id => self.id, :device => "Device::ConsoleDevice") unless alert_device_types.map(&:device).include?("Device::ConsoleDevice")
  end
  
  private
  def set_alert_type
    self[:alert_type] = "VmsAlert"
  end
end