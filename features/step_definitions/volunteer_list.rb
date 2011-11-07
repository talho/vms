Given /^a status check alert created on "([^\"]*)" for:$/ do |date, table|
  al = VmsStatusCheckAlert.default_alert
  al.created_at = DateTime.strptime(date, '%m/%d/%y %H:%M:%S').change(:offset => 'CDT')
  al.author = current_user
  al.audiences << Audience.new( :users => table.raw.flatten.map {|r| User.find_by_display_name(r)} )
  al.save
end