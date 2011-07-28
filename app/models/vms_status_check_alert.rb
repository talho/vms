
class VmsStatusCheckAlert < VmsAlert
  acts_as_MTI
  set_table_name 'view_status_check_vms_alerts'
  before_create :create_email_alert_device_type, :set_alert_type, :set_acknowledge
  
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsStatusCheckAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.to_s}" }, :app => 'vms' }
  
  def to_s
    title || ''
  end
  
  def self.default_alert
    title = "Volunteer Status Check"
    message = ""
    VmsStatusCheckAlert.new(:title => title, :message => message, :created_at => Time.zone.now, :acknowledge => true)
  end
  
  def formatted_message(user)
    jurs = build_jurisdictions_string(user)
    "#{self.author.display_name} has initiated a status check for the #{jurs} jurisdiction(s). Please acknowledge that you have received this message and still wish to volunteer in #{jurs}."
  end
  
  def to_xml()
    options = {:Messages => {}, :Recipients => {}, :IVRTree => {} }
    
    options[:Messages][:override] = Proc.new do |messages|
      role_names = []
      messages.Message(:name => 'title') {|msg| msg.Value self.title }
      messages.Message(:name => 'msg1') {|msg| msg.Value "#{self.author.display_name} has initiated a status check for the "}
      messages.Message(:name => 'juris') {|msg| msg.Value ""}
      messages.Message(:name => 'msg2') {|msg| msg.Value " jurisdiction(s). Please acknowledge that you have received this message and still wish to volunteer in "}
      messages.Message(:name => 'msg3') {|msg| msg.Value "."}
      
      messages.Message(:name => 'custom_msg') {|msg| msg.Value "\n\n#{self.message}"} unless self.message.blank?
    end
    
    options[:IVRTree][:override] = Proc.new do |ivrtree|
      ivrtree.IVR(:name => 'message_ivr') do |ivr|
        ivr.RootNode(:operation => 'start') do |root_node|
          root_node.ContextNode do |ctxt|
            ctxt.operation 'put'
            ctxt.response(:ref => 'msg1')
            ctxt.response(:ref => 'juris')
            ctxt.response(:ref => 'msg2')
            ctxt.response(:ref => 'juris')
            ctxt.response(:ref => 'msg3')
            ctxt.response(:ref => 'custom_msg') unless self.message.blank?
          end
          root_node.ContextNode do |ctxt|
            ctxt.operation 'prompt'
          end
        end
      end
    end
        
    options[:Recipients][:override] = Proc.new do |rcpts|
      User.find_each(:joins => "INNER JOIN targets_users ON targets_users.user_id=users.id INNER JOIN targets ON targets_users.target_id=targets.id AND targets.item_type='#{self.class.to_s}'", :conditions => ['targets.item_id = ?', self.id]) do |s|
        rcpts.Recipient(:id => s.id, :givenName => s.first_name, :surname => s.last_name, :display_name => s.display_name) do |rcpt|
          (s.devices.find_all_by_type(self.alert_device_types.map(&:device))).each do |device|
            rcpt.Device(:id => device.id, :device_type =>  device.class.display_name) do |d|
              d.URN device.URN
              vols = build_jurisdictions_string(s)
              d.Message(:name => 'juris') {|msg| msg.Value vols}
            end
          end
        end
      end
    end
    
    super(options)
  end
  
  private
  def set_alert_type
    self[:alert_type] = "VmsStatusCheckAlert"
  end
 
  def set_acknowledge
    self[:acknowledge] = true
  end
 
  def build_jurisdictions_string(user)
    jurs = user.jurisdictions.vms_volunteer.map(&:name)
    jurs.last.insert(0, 'and ') if jurs.count > 1
    jurs = jurs.join(jurs.count == 2 ? ' ' : ', ')
  end
end