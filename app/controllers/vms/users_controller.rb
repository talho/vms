class Vms::UsersController < ApplicationController
  
  skip_before_filter :login_required, :only => [:new, :create]
  
  def new
    @user = User.new
    @user[:vms_jurisdiction_id] = nil
    @jurisdictions = Jurisdiction.all.sort_by{|j| j.name}
#    respond_to do |format|
#      format.html {
#        render :layout => 'talho_app'
#      }
#    end
  end
  def create
    jurisdiction = params[:user]["vms_jurisdiction_id"].blank? ? nil : Jurisdiction.find(params[:user]["vms_jurisdiction_id"])
    params[:user].delete("vms_jurisdiction_id")
    vms_volunteer_role = Role.find_by_name_and_application('Volunteer', 'vms')

    @user = User.new params[:user]
    @user.role_memberships.build(:role=>vms_volunteer_role, :jurisdiction=>jurisdiction, :user=>@user)

    @user.email = @user.email.downcase
    respond_to do |format|
      if @user.save
        SignupMailer.deliver_confirmation(@user)
        format.html { redirect_to sign_in_path }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
        flash[:notice] = "Thanks for signing up! An email will be sent to #{@user.email} shortly to confirm your account. Once you've confirmed you'll be able to login to TXPhin.\n\nIf you have any questions please email support@#{DOMAIN}."
      else
        @user[:vms_jurisdiction_id] = jurisdiction.blank? ? nil : jurisdiction.id
        @jurisdictions = Jurisdiction.all.sort_by{|j| j.name}
        #@selected_role = params[:user][:role_requests_attributes]['0']['role_id'].to_i if defined? params[:user][:role_requests_attributes]['0']['role_id']
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

#linking apps to existing users not supported at this time;  will be performed manually by a sysadmin.
#  def link_app
#    vms_volunteer_role = Role.find_by_name_and_application('Volunteer', 'vms')
#    jurisdiction = Jurisdiction.find(params[:user]["vms_jurisdiction_id"])
#    if current_user.is_admin_for?('phin')
#      req = RoleRequest.new(:role=>vms_volunteer_role, :jurisdiction=>jurisdiction, :user=>current_user)
#      req.save
#      flash[:notice] = "VMS Volunteer role requested"
#    else
#      rm = RoleMembership.new(:role=>vms_volunteer_role, :jurisdiction=>jurisdiction, :user=>current_user)
#      rm.save
#      flash[:notice] = "You are now a VMS Volunteer!"
#    end
#
#    params.delete("vms_jurisdiction_id")
#
#    respond_to do | format |
#      format.html { render :layout => false }
#    end
#  end
#
#  def link_app_page
#    current_user[:vms_jurisdiction_id] = nil
#    @jurisdictions = Jurisdiction.all.sort_by{|j| j.name}
#  end

end