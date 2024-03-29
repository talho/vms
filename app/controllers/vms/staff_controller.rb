class Vms::StaffController < ApplicationController
  include Vms::PopulateScenario
  
  before_filter :non_public_role_required
  before_filter :initialize_scenario, :only => [:index, :show]
  before_filter :initialize_protected_scenario, :only => [:update]
  
  def index
    @staff = params[:site_id] ? @scenario.site_instances.for_site(params[:site_id].to_i).staff : @scenario.staff
    @walkups = params[:site_id] ? @scenario.site_instances.for_site(params[:site_id].to_i).walkups : @scenario.walkups
    @staff.each do |s|
      u = s.user
      s[:user_detail] = {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                         :tip => render_to_string(:partial => 'searches/extra.json', :locals => {:user => u})}
    end if params[:with_detail]
    @walkups.inject(@scenario.staff.to_a){|s,w| s.push(w)}
    respond_to do |format|
      format.json {render :json => @staff.as_json }
    end
  end
  
  def show
    @site_instance = @scenario.site_instances.for_site(params[:site_id])
    @staff = @site_instance.staff.find(:all, :include => [:user , :site])
    @walkups = @site_instance.walkups
    @staff.each do |s|
      u = s.user
      s[:user_detail] = {:caption => "#{u.name} #{u.email}", :name => u.name, :email => u.email, :id => u.id, :title => u.title,
                         :tip => render_to_string(:partial => 'searches/extra.json', :locals => {:user => u})}
    end
    respond_to do |format|
      format.json {render :json => @staff.as_json }
    end
  end
  
  def update
    @site_instance = @scenario.site_instances.first( {:conditions => {:site_id => params[:site_id]}, :include => [:role_scenario_sites] })
    
    # pull out new, updated, and deleted staff from params
    new_staff = params[:added_staff].nil? ? [] : JSON.parse(params[:added_staff])
    updated_staff = params[:updated_staff].nil? ? [] : JSON.parse(params[:updated_staff])
    deleted_staff = params[:removed_staff].nil? ? [] : JSON.parse(params[:removed_staff])

    current_staff = @site_instance.staff

    deleted_users_for_alerts = []
    #delete existing staff
    deleted_staff.each do |s|
      db_staff = current_staff[current_staff.index{ |ts| ts.id === s['id']}]
      db_staff.mark_for_destruction
      deleted_users_for_alerts << db_staff.user
    end
    Vms::Staff.delay.send_removed_message(deleted_users_for_alerts, @scenario) unless deleted_users_for_alerts.blank?
    
    added_staff_for_alerts = []
    #create new staff
    new_staff.each do |s|
      #first, check to see if the user is already assigned to a different site instance
      st = @scenario.staff.find_by_user_id(s['user_id'])
      st.destroy unless st.nil?
      added_staff_for_alerts << @site_instance.staff.build(s)
    end
    Vms::Staff.delay.send_added_message(added_staff_for_alerts, @site_instance) unless added_staff_for_alerts.blank?
    
    updated_staff_for_alerts = []
    #update existing staff
    updated_staff.each do |s|
      updated_staff_for_alerts << db_staff = current_staff[current_staff.index{ |ts| ts.id === s['id']}]
      db_staff.attributes = s
    end
    Vms::Staff.delay.send_updated_message(updated_staff_for_alerts) unless updated_staff_for_alerts.blank?

    @site_instance.site_admin_id = params[:site_admin] unless params[:site_admin].nil?

    respond_to do |format|
      if @site_instance.save
        format.json {render :json => {:success => true} }
      else
        format.json {render :json => {:success => false, :errors => @site_instance.errors}, :status => 400}
      end
    end
    
  end
    
end