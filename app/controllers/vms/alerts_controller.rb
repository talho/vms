class Vms::AlertsController < ApplicationController  
  before_filter :non_public_role_required, :change_include_root
  after_filter :change_include_root_back
  
  ## List the alerts for a current user. Handle paging requests
  def index
    page = ( (params[:start]||0).to_i/(params[:limit]||10).to_i ) + 1
    per_page = params[:limit] || 10
    aas = current_user.alert_attempts.find_all_by_alert_type(['VmsAlert', 'VmsStatusAlert', 'VmsExecutionAlert', 'VmsStatusCheckAlert']).paginate(:page => page, :per_page => per_page)
    
    # reformat the alert object so that the json comes back as expected
    aas.each do |aa|
     aa[:name] = aa.alert.title
     aa[:message] = aa.alert.formatted_message(current_user)
     aa[:author] = aa.alert.author.display_name if aa.alert.author
     aa[:calldowns] = aa.alert.call_downs(current_user) if aa.alert_type.constantize == VmsExecutionAlert
     aa[:scenario_name] = aa.alert.scenario.name if aa.alert.scenario
     aa[:acknowledge] = aa.alert.acknowledge
    end
    
    respond_to do |format|
      format.json {render :json => {:alerts => aas.map{|a| a.as_json(:only => [:id, :acknowledged_at, :created_at, :call_down_response, :alert_type, :name, :message, :author, :calldowns, :scenario_name, :acknowledge])}, :total => aas.total_entries } }
    end
  end
  
  def create
    # create a new vms alert. This can either be a base VmsAlert or a VmsStatusCheckAlert
    
    # Find out which alert it is
    alert = (params[:alert_type] || "VmsAlert").constantize.default_alert
    alert.title = params[:title] unless params[:title].blank?
    alert.message = params[:message] unless params[:message].blank?
    users = params[:user_ids].map(&:to_i) # push the user ids to int, just to avoid issues
    alert.audiences << (Audience.new :user_ids => users)
    alert.author = current_user
    
    respond_to do |format|
      if alert.save
        format.json {render :json => {:success => true}}
      else
        format.json {render :json => {:success => false, :errors => alert.errors}, :status => 400 }
      end
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
  
  def status_checks
    page = ( (params[:start]||0).to_i/(params[:limit]||50).to_i ) + 1
    per_page = params[:limit] || 50
    checks = VmsStatusCheckAlert.find_all_by_author_id(current_user.id).paginate(:page => page, :per_page => per_page)
    
    respond_to do |format|
      format.json {render :json => {:status_checks => checks, :total => checks.total_entries}}
    end
  end
  
  def show
    al = VmsStatusCheckAlert.find(params[:id])
    al = al.alert_type.constantize.find(al)
    
    respond_to do |format|
      format.json {render :json => {:alert_attempts => al.alert_attempts.as_json } }
    end
  end
  
end