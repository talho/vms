
class VmsAlert < Alert
  set_table_name 'alerts'
  default_scope :conditions => {:alert_type => 'VmsAlert'}  
  before_create :set_alert_type
  before_create :create_email_alert_device_type
  
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
    
  def to_s
    title || ''
  end
  
  def self.default_alert
    title = "VMS Status Alert"
    message = "This alert is intended to update the user of a status change in the VMS system"
    Alert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end
  
  private
  def set_alert_type
    self[:alert_type] = "VmsAlert"
  end
  
  def create_email_alert_device_type
    alert_device_types << AlertDeviceType.new(:alert_id => self.id, :device => "Device::EmailDevice") unless alert_device_types.map(&:device).include?("Device::EmailDevice")
  end
end