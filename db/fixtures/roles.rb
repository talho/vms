p 'Writing Roles'
r = Role.find_or_create_by_name_and_application('Admin', 'vms')
p "#{r.name} - #{r.application}"
 
j = Jurisdiction.find_by_name("Angelina") #set up a bunch of users in Angelina county in order to provide a vms test bed
p "Found #{j.name}"

if j
  p "Adding vms roles to users"
  u = User.find_by_email('eddie@talho.org')  
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  
  r = Role.find_or_create_by_name_and_application('Volunteer', 'vms')

  u = User.find_by_email('bob@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  u = User.find_by_email('ethan@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  u = User.find_by_email('brandon@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  u = User.find_by_email('daniel@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  u = User.find_by_email('zach@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
  u = User.find_by_email('awesome@example.com')
  u.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(r.id, j.id) if u && r && j
end

