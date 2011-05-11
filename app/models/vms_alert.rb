
class VmsAlert < Alert
  set_table_name 'alerts'
  default_scope :conditions => {:alert_type => 'VmsAlert'}  
  before_create :set_alert_type
  
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
end