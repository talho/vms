
When /^backgroundrb has processed the vms alert responses$/ do
  require 'vendor/plugins/backgroundrb/server/lib/bdrb_server_helper.rb'
  require 'vendor/plugins/backgroundrb/server/lib/meta_worker.rb'
  require 'vendor/plugins/vms/lib/workers/watch_for_vms_execution_alert_responses_worker.rb'
  WatchForVmsExecutionAlertResponsesWorker.new.query
end

When /^"([^\"]*)" has responded to a ([^ ]*)(?: with title "([^\"]*)")? with ([0-9]*)$/ do |name, alert_type, title, count|
  conditions = {:alert_type => alert_type}
  conditions['alerts.title'] = title unless title.nil?
  user = User.find_by_display_name(name)
  aa = AlertAttempt.find_by_user_id(user.id, :joins => "INNER JOIN alerts ON alert_attempts.alert_id = alerts.id",
                                         :conditions => conditions)
  aa = AlertAttempt.find(aa.id)

  aa.update_attributes :acknowledged_at => Time.now, :call_down_response => count.to_i
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
    status &&= email.body =~ /#{Regexp.escape(message.gsub(/\\n/, "\n"))}/ unless message.nil?
    status
  end
  
  email.should_not be_nil if neg.nil?
  email.should be_nil if !neg.nil?
end