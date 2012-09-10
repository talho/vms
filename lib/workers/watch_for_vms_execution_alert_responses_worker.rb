class WatchForVmsExecutionAlertResponsesWorker < BackgrounDRb::MetaWorker
  set_worker_name :watch_for_vms_execution_alert_responses_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def query(args = nil)
    #find a better way to determine if an alert attempt acknowledgement is new and unhandled
    attempts = AlertAttempt.find_all_by_alert_type('VmsExecutionAlert', :conditions => ['acknowledged_at >= ?', 1.minute.ago])
    
    attempts.each do |attempt|
      
      next if attempt.call_down_response.nil? || attempt.call_down_response.to_i == 1
      
      roles = sort_roles_for_responses(attempt.alert.vms_volunteer_roles.find_all_by_volunteer_id(attempt.user) )
      
      if attempt.call_down_response.to_i != roles.count + 2
        # the user responded that they will fill a speficic role
        roles = [ roles[attempt.call_down_response.to_i - 2] ]
      end
      atalert = attempt.alert.class.find(attempt.alert.id) # When alert is called as an association, it doesn't respect the default scope on the Alert class, at least for now. Get around that here.
      rsss = atalert.scenario.role_scenario_sites.find(:all, :conditions => {:role_id => roles.compact.map(&:role_id)})
      rsss.each do |rss|
        rss.calculate_assignment(rss.scenario_site.all_staff.map(&:user))
      end
      rsss = prioritize_roles(rsss, attempt.user.qualification_list) # we send the user qualifications in here because we want to fill in missing roles with people who have qualifications first
      
      al = VmsAlert.new
      if rsss.count > 0
        #assign to site, send acceptance response
        rsss.first.scenario_site.staff.create :user => attempt.user, :status => 'assigned', :source => 'auto'
        al.attributes = {:title => "You have been assigned", :author => attempt.alert.author, :scenario => attempt.alert.scenario,
                         :message => "You have been selected as a volunteer. You have been assigned the role #{rsss.first.role.name} at:
#{rsss.first.scenario_site.site.name}
#{rsss.first.scenario_site.site.address}"}
        al.audiences << (Audience.new :users => [attempt.user])
      else
        #send rejection response
        al.attributes = {:title => "Thank you", :author => attempt.alert.author, :scenario => attempt.alert.scenario,
                         :message => "Thank you for volunteering. At this time all roles have been filled. You will be notified if your services are needed at a later time."}
        al.audiences << (Audience.new :users => [attempt.user])
      end
      al.save
    end
  end
  
  def sort_roles_for_responses(roles)
    roles.sort{|a,b| a.id <=> b.id}
  end
  
  def prioritize_roles(rsss, user_qualifications)
    rsss.reject{|r| r[:missing] <= 0}.sort do |a, b|
      a_pct = a[:missing]/a.count
      b_pct = b[:missing]/b.count
      if a_pct == b_pct
        a_quals = (a.qualification_list + a.scenario_site.qualification_list).uniq & user_qualifications
        b_quals = (b.qualification_list + b.scenario_site.qualification_list).uniq & user_qualifications
        b_quals.count <=> a_quals.count
      else
        b_pct <=> a_pct
      end
    end
  end
end