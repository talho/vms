
class VmsExecutionAlert < VmsAlert
  include ActionController::UrlWriter
  acts_as_MTI
  set_table_name 'view_execution_vms_alerts'
  
  before_create :before_vol_roles, :set_defaults
  after_create :after_vol_roles
  
  has_many :vms_volunteer_roles, :class_name => "Vms::VolunteerRole", :foreign_key => :alert_id, :autosave => true
  has_many :volunteers, :class_name => "User", :through => :vms_volunteer_roles, :uniq => true
  has_many :recipients, :class_name => "User", :finder_sql => 'SELECT users.* FROM users, targets, targets_users WHERE targets.item_type=\'VmsExecutionAlert\' AND targets.item_id=#{id} AND targets_users.target_id=targets.id AND targets_users.user_id=users.id'
  
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| "#{x.scenario.name} - #{x.to_s}" }, :app => 'vms' }
  
  def self.default_alert
    title = "VMS Execution Alert"
    message = "This alert is looking for volunteers for the newly executing scenario"
    VmsExecutionAlert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end
  
  def call_downs (user, roles = nil)
    vol_roles = roles || self.vms_volunteer_roles.find_all_by_volunteer_id(user).map(&:role)
    calldowns = [
      {:msg => "1) I cannot respond", :value => 1, :polarity => 'negative'},
      {:msg => "#{vol_roles.count + 2}) I can respond as any role", :value => vol_roles.count + 2, :polarity => 'positive'}
    ]
    vol_roles.each_index do |i|
      calldowns << {:msg => "#{i + 2}) I can respond as #{vol_roles[i].name}", :value => i + 2, :polarity => 'positive'}
    end
    calldowns.sort_by{|c| c[:value]}
  end
  
  def formatted_message(user, roles = nil)
    vol_roles = roles || self.vms_volunteer_roles.find_all_by_volunteer_id(user).map(&:role)
    "There has been a call for volunteers put out. Users with roles #{vol_roles.map(&:name).join(', ')} are needed and we show you can fill at least one of these roles. Please indicate if you will respond to this scenario:"
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
    options = {:Messages => {}, :Recipients => {}, :IVRTree => {} }
    
    vhash = vol_role_hash
    
    options[:Messages][:override] = Proc.new do |messages|
      role_names = []
      messages.Message(:name => 'title') {|msg| msg.Value self.title }
      messages.Message(:name => 'msg_body_1') {|msg| msg.Value "There has been a call for volunteers put out. Users with roles "}
      messages.Message(:name => 'role_list') {|msg| msg.Value ""}
      messages.Message(:name => 'msg_body_2') {|msg| msg.Value " are needed and we show you can fill at least one of these roles. Please indicate if you will respond to this scenario:\n"}
      messages.Message(:name => 'role_opts') {|msg| msg.Value "1) I cannot respond\n2) I can respond as any role"}
      vhash.each do |vol, roles|
        role_name = build_role_name(roles)
        unless role_names.include?(role_name)
          role_names << role_name
          messages.Message(:name => "#{role_name}_list") {|msg| msg.Value "#{roles.map(&:name).join(', ')}"}
          messages.Message(:name => "#{role_name}_opts") do |msg|
            msg.Value self.call_downs(vol, roles).map{|cd| cd[:msg]}.join("\n")
          end
        end
      end
    end
    
    vols = volunteers
    vols = vms_volunteer_roles.map(&:volunteer).uniq if vols.empty?
    
    options[:Recipients][:override] = Proc.new do |rcpts|
       vols.each do |recipient|
        rcpts.Recipient(:id => recipient.id, :givenName => recipient.first_name, :surname => recipient.last_name, :display_name => recipient.display_name) do |rcpt|
          (recipient.devices.find_all_by_type(self.alert_device_types.map(&:device)) | [Device::ConsoleDevice.new]).each do |device|
            rcpt.Device(:id => device.respond_to?('attributes') ? device.id : '', :device_type =>  device.class.display_name) do |d|
              d.URN device.URN if device.respond_to?("URN")
              role_name = build_role_name(vhash[recipient])
              d.Message(:name => 'role_list', :ref => "#{role_name}_list")
              d.Message(:name => 'role_opts', :ref => "#{role_name}_opts")
              aa = self.alert_attempts.find_by_user_id(recipient.id)
              url = alert_with_token_url :id => self.id, :token => aa.token, :host => HOST
              d.Message(:name => 'alert_url'){|msg| msg.Value url}
            end
          end
        end if vol_role_hash[recipient]
      end
    end
    
    options[:IVRTree][:override] = Proc.new do |ivrtree|
      ivrtree.IVR(:name => 'message_ivr') do |ivr|
        ivr.RootNode(:operation => "start") do |rootnode|
          rootnode.ContextNode do |ctxt|
            ctxt.operation 'put'
            ctxt.response(:ref => 'msg_body_1')
            ctxt.response(:ref => 'role_list')
            ctxt.response(:ref => 'msg_body_2')
            ctxt.response(:ref => 'role_opts')
          end
          rootnode.ContextNode do |ctxt|
            ctxt.operation 'prompt'
            ctxt.response(:ref => 'alert_url')
            ctxt.ContextNode(:operation => 'display') do |ictxt|
              ictxt.response() {|ppt| ppt.Value 'Select a response.' }
            end
          end
        end
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
  
  def set_defaults
    self.acknowledge = true
  end
  
end