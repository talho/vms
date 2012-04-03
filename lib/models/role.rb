require 'action_controller/deprecated/dispatcher'

module Vms
  module Role
    def volunteers
      users.scoped(:joins => ['INNER JOIN role_memberships as s_rm on s_rm.user_id = users.id',
                              'INNER JOIN roles as s_r on s_r.id = s_rm.role_id'],
                   :conditions => "s_r.name = 'Volunteer' and s_r.application = 'vms'")
    end
  end
  
  ActionController::Dispatcher.to_prepare do
    ::Role.send(:include, Vms::Role)
  end
end

