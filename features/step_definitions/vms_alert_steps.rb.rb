
Then /^"([^\"]*)" should( not)? receive a ([^ ]*)(?: with)?(?: title "([^\"]*)")?(?: message "([^"]*)")?$/ do |name, neg, alert_type, title, message|
  conditions = {:alert_type => alert_type}
  conditions['alerts.title'] = title unless title.nil?
  conditions['alerts.message'] = message.gsub(/\\n/, "\n") unless message.nil?
  user = User.find_by_display_name(name)
  aa = AlertAttempt.find_by_user_id(user.id, :joins => "INNER JOIN alerts ON alert_attempts.alert_id = alerts.id",
                                         :conditions => conditions)

  if neg.nil?
    aa.should_not be_nil
  else
    aa.should be_nil
  end
end

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