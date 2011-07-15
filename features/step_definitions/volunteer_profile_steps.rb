
Then /^I should not see the volunteer profile menu option$/ do
  # Look for the apps menu
  pass = false
  begin
    Then %{I should see the following toolbar items in "top_toolbar":}, table(%{| Apps |})
  rescue
    pass = true # the step passes if Apps is not defined
  end

  if !pass
    begin
      When %{I press "Apps" within "#top_toolbar"}
      Then %{I should see the following ext menu items:}, table(%{
        | name |
        | VMS  |
      })
    rescue
      pass = true # the step passes if VMS is not defined
    end

    if !pass
      When %{I click x-menu-item "VMS" within ".x-menu"}
      When %{I wait until I have 2 ext menus}
      Then %{I should not see the following ext menu items:}, table(%{
          | name                 |
          | My Volunteer Profile |
      })
    end
  end
end
When /^user "([^\"]*)" has the "([^\"]*)" qualification$/ do |user_name, qualification_name|
  u = User.find_by_display_name(user_name)
  u.qualification_list << qualification_name.downcase
  u.save
end