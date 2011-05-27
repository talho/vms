
class VmsExecutionAlert < VmsAlert
  acts_as_MTI
  set_table_name 'view_execution_vms_alerts'
  
  before_create :before_vol_roles
  after_create :after_vol_roles
  
  has_many :vms_volunteer_roles, :class_name => "Vms::VolunteerRole", :foreign_key => :alert_id, :autosave => true
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsExecutionAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
  
  def self.default_alert
    title = "VMS Execution Alert"
    message = "This alert is looking for volunteers for the newly executing scenario"
    VmsExecutionAlert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end
  
  def vol_role_hash
    v_hash = {}
    vms_volunteer_roles.each do |vr|
      if v_hash.key?(vr.volunteer)
        v_hash[vr.volunteer] << vr.role
      else
        v_hash[vr.volunteer] = [vr.role]
      end
    end
    
    v_hash
  end
  
  def to_xml
    options = {:Messages => {}, :Recipients => {}, :Behavior => {:Delivery => {:Providers => {} } }, :IVRTree => {} }
    
    
    options[:Messages][:supplement] = Proc.new do |messages|
      role_names = []
      vol_role_hash.each do |vol, roles|
        role_name = build_role_name(roles)
        messages.Message(:name => role_name, :lang => "en/us", :encoding => "utf8", :content_type => "text/plain") do |message|
          message.Value "There has been a call for volunteers put out. Users with roles #{roles.map(&:name).join(', ')} are needed and we show you can fill at least one of these roles. Please indicate if you will respond to this scenario:"
          role_names << role_name
        end unless role_names.include?(role_name)
      end
    end
    
    options[:Recipients][:override] = Proc.new do |rcpts|
      User.find_each(:joins => "INNER JOIN targets_users ON targets_users.user_id=users.id INNER JOIN targets ON targets_users.target_id=targets.id AND targets.item_type='#{self.class.to_s}'", :conditions => ['targets.item_id = ?', self.id]) do |recipient|
        rcpts.Recipient(:id => recipient.id, :givenName => recipient.first_name, :surname => recipient.last_name, :display_name => recipient.display_name) do |rcpt|
          (recipient.devices.find_all_by_type(self.alert_device_types.map(&:device))).each do |device|
            rcpt.Device(:id => device.id, :device_type =>  device.class.display_name) do |d|
              d.URN device.URN
              role_name = build_role_name(vol_role_hash[recipient])
              d.Message(:name => 'message', :ref => role_name)
            end
          end
        end if vol_role_hash[recipient]
      end
    end
    
    options[:Behavior][:Delivery][:Providers][:supplement] = Proc.new do |providers|
      role_names = []
      vol_role_hash.each do |vol, roles|
        role_name = build_role_name(roles)
        (self.alert_device_types.map{|device| device.device_type.display_name} || Service::SWN::Message::SUPPORTED_DEVICES.keys).each do |device|
          providers.Provider(:name => "swn", :device => device, :ivr => role_name) do |provider|
            provider.Messages do |messages|
              messages.ProviderMessage(:name => 'message', :ref => role_name)
            end
          end
          role_names << role_name
        end unless role_names.include?(role_name)
      end
    end
    
    options[:IVRTree][:override] = Proc.new do |ivrtree|
      role_names = []
      vol_role_hash.each do |vol, roles|
        role_name = build_role_name(roles)
        ivrtree.IVR(:name => role_name) do |ivr|
          ivr.RootNode(:operation => "start") do |rootnode|
            rootnode.ContextNode do |node|
              node.label 1
              node.operation "TTS"
              node.response "I cannot respond"
            end
            roles.each do |r|
              rootnode.ContextNode do |node|
                node.label roles.index(r) + 2
                node.operation "TTS"
                node.response "I can respond as #{r.name}"
              end
            end
            rootnode.ContextNode do |node|
              node.label roles.count + 2
              node.operation "TTS"
              node.response "I can respond as any role"
            end
            rootnode.ContextNode do |response_node|
              response_node.label "Prompt"
              response_node.operation "Prompt"
            end
          end
          role_names << role_name
        end unless role_names.include?(role_name)
      end
    end
    
    super(options);
  end
  
  private
  
  def before_vol_roles
    @vol_roles = vms_volunteer_roles
    true
  end
  
  def after_vol_roles
    @vol_roles.each do |vr|
      vr.alert = self
      vr.save
    end
  end
  
  def build_role_name(roles)
    "Roles_" + roles.sort_by{|a,b| a.id <=> (b.nil? ? nil : b.id)}.map(&:id).join('_')
  end
  
end