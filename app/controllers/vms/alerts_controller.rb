class Vms::AlertsController < ApplicationController  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  ## List the alerts for a current user. Handle paging requests
  def index
    page = ( (params[:start]||0).to_i/(params[:limit]||10).to_i ) + 1
    per_page = params[:limit] || 10
    aas = current_user.alert_attempts.find_all_by_alert_type(['VmsAlert', 'VmsStatusAlert', 'VmsExecutionAlert']).paginate(:page => page, :per_page => per_page)
    
    # reformat the alert object so that the json comes back as expected
    aas.each do |aa|
     aa[:name] = aa.alert.title
     aa[:message] = aa.alert.formatted_message(current_user)
     aa[:author] = aa.alert.author.display_name if aa.alert.author
     aa[:calldowns] = aa.alert.call_downs(current_user) if aa.alert_type.constantize == VmsExecutionAlert
     aa[:scenario_name] = aa.alert.scenario.name
    end
    
    respond_to do |format|
      format.json {render :json => {:alerts => aas.map{|a| a.as_json(:only => [:id, :acknowledged_at, :created_at, :call_down_response, :alert_type, :name, :message, :author, :calldowns, :scenario_name])}, :total => aas.total_entries } }
    end
  end
  
  ## Acknowledge an alert for the user. Should be a resource member route
  def acknowledge
    respond_to do |format|
      response = params[:response].to_i
      if response == 0
        format.json {render :json => {:success => false, :msg => "Response must be an integer value"}, :status => 400}
        return #return that response is required
      end
      
      aa = AlertAttempt.find(params[:id]) # naming is probably bad here, the ID that we're working with is acutally an alert attempt id. That's ok, though
      
      if aa.update_attributes :acknowledged_at => Time.now, :call_down_response => response
        format.json {render :json => {:success => true}}
      else
        format.json {render :json => {:success => false, :msg => aa.errors}, :status => 400}
      end
    end
  end
  
end