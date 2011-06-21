class Vms::SessionsController < ApplicationController
  skip_before_filter :login_required
  #TODO: before_filter vms_app_required

  def new
    if current_user.blank?
      render :layout => 'vms_kiosk'
    else   # user has a valid Phin session.  If they are a site admin, we auto-auth them for VMS
      if User.find(session[:user_id]).is_vms_scenario_site_admin?
        session[:vms_user_id] = session[:user_id]
        redirect_to :kiosk_index
      else
        flash[:error] = "You are not a VMS Site Administrator"
        redirect_to :sign_in
      end
    end
  end

  def create
    @user = User.authenticate(params['session']['email'], params['session']['password'])
    if @user
      if @user.is_vms_scenario_site_admin?
        session.delete(:user_id)   # kill the phin login session
        session[:vms_user_id] = @user.id
        redirect_to :kiosk_index
      else
        flash[:error] = "You are not a VMS Site Administrator"
        redirect_to :sign_in
      end
    else
      flash[:error] = "Invalid email or password"
      redirect_to :vms_session_new
    end
  end

  def destroy
    session.delete(:vms_user_id)
    flash[:notice] = "You have logged out of the Volunteer Management System."
    redirect_to :vms_session_new
  end

end
