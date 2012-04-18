
module Vms
  module Role
    def volunteers
      users.joins('INNER JOIN role_memberships as s_rm on s_rm.user_id = users.id').joins('INNER JOIN roles as s_r on s_r.id = s_rm.role_id').where("s_r.name = 'Volunteer' and s_r.application = 'vms'")
    end
  end
  
end

