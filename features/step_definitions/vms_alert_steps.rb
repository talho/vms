
When /^backgroundrb has processed the vms alert responses$/ do
  require 'vendor/plugins/backgroundrb/server/lib/bdrb_server_helper.rb'
  require 'vendor/plugins/backgroundrb/server/lib/meta_worker.rb'
  require 'vendor/plugins/vms/lib/workers/watch_for_vms_execution_alert_responses_worker.rb'
  WatchForVmsExecutionAlertResponsesWorker.new.query
end

When /^"([^\"]*)" has responded to a ([^ ]*)(?: with title "([^\"]*)")? with ([0-9]*)(?: at "([^"]*)")?$/ do |name, alert_type, title, count, time|
  conditions = {:alert_type => alert_type}
  conditions['alerts.title'] = title unless title.nil?
  user = User.find_by_display_name(name)
  aa = AlertAttempt.find_by_user_id(user.id, :joins => "INNER JOIN alerts ON alert_attempts.alert_id = alerts.id",
                                         :conditions => conditions)
  aa = AlertAttempt.find(aa.id)

  aa.update_attributes :acknowledged_at => time.nil? ? Time.now : Time.parse(time), :call_down_response => count.to_i
end

Then /^"([^\"]*)" should( not)? receive a VMS email(?: with)?(?: title "([^\"]*)")?(?: message "([^"]*)")?$/ do |user_email, neg, title, message|
  email = ActionMailer::Base.deliveries.detect do |email|
    status = false
    if(!email.bcc.blank?)
      status ||= email.bcc.include?(user_email)
    end
    if(!email.to.blank?)
      status ||= email.to.include?(user_email)
    end

    status &&= email.subject =~ /#{Regexp.escape(title)}/ unless title.nil?
    status &&= email.body.gsub(/<br ?\/>/, '') =~ /#{Regexp.escape(message.gsub(/\\n/, "\n"))}/ unless message.nil?
    status
  end
  
  email.should_not be_nil if neg.nil?
  email.should be_nil if !neg.nil?
end

Given /^"([^\"]*)" has received the following alert for scenario "([^"]*)":$/ do |user, scenario, table|
  user = User.find_by_display_name(user)
  h = table.rows_hash
  al_type = h['type'].constantize
  alert = al_type.new :message => h['message'], :title => h['title'], :created_at => Time.now
  alert.scenario_id = Vms::Scenario.find_by_name(scenario).id
  alert.audiences << (Audience.new :users => [user])

  if al_type == VmsExecutionAlert
    # add find the roles option and add those roles
    role_names = h['roles'].split(',')
    role_names.each do |role_name|
      alert.vms_volunteer_roles << (Vms::VolunteerRole.new :volunteer => user, :role => Role.find_by_name(role_name) )
    end
  end

  alert.save!
end

Then /^the user "([^\"]*)" should have responded to the alert "([^\"]*)" with ([0-9]*)$/ do |user_name, alert_title, value|
  alert = Alert.find_by_title(alert_title)
  alert = alert.alert_type.constantize.find(alert) # cast the alert into the expected alert_type
  aa = alert.alert_attempts.find_by_user_id(User.find_by_display_name(user_name) )
  aa.call_down_response.to_i.should == value.to_i
end