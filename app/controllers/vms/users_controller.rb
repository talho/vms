class Vms::UsersController < Clearance::UsersController
  
  def new
    @user = User.new
    @user[:vms_jurisdiction_id] = nil
    @jurisdictions = Jurisdiction.all.sort_by{|j| j.name}
  end
  
  def create
    jurisdiction = params[:user]["vms_jurisdiction_id"].blank? ? nil : Jurisdiction.find(params[:user]["vms_jurisdiction_id"])
    params[:user].delete("vms_jurisdiction_id")
    vms_volunteer_role = Role.find_by_name_and_application('Volunteer', 'vms')

    @user = ::User.new params[:user]
    @user.role_memberships.build(:role=>vms_volunteer_role, :jurisdiction=>jurisdiction, :user=>@user)

    @user.email = @user.email.downcase
    if @user.save
      sign_in(@user)
      redirect_back_or(url_after_create)
    else
      flash_failure_after_create
      @user[:vms_jurisdiction_id] = jurisdiction.blank? ? nil : jurisdiction.id
      @jurisdictions = Jurisdiction.all.sort_by{|j| j.name}
      render :template => 'users/new' 
    end
  end

end