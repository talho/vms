
When /^I click the marker for "([^\"]*)"$/ do |site_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var i = command_center.siteGrid.getStore().find('name', new RegExp('#{site_name}'));
    var rec = command_center.siteGrid.getStore().getAt(i);
    var marker = command_center.findMarker(rec);
    command_center.showSiteMarkerInfo(marker);
  ")
end

Then /^the info window for "([^\"]*)" should( not)? be open$/ do |site_name, neg|
  Then %{I should #{neg.nil? ? "" : "not "}see "#{site_name}" within ".site_info_window"}
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    return command_center.current_site_info_window.marker.data.record.get('name') #{neg.nil? ? "==" : "!="} '#{site_name}'
  ").should be_true
end

Then /^I should see staff information for "([^\"]*)"$/ do |staff_or_team_name|
  case staff_or_team_name
    when "Just Atticus"
      Then %{I should see "Staff - 0/1" within ".site_info_window .staff_grid"}
      Then %{I should see "Atticus Finch" in grid row 1 within ".site_info_window .staff_grid"}
    when "Atticus & Team"
      Then %{I should see "Staff - 0/2" within ".site_info_window .staff_grid"}
      Then %{I should see "Atticus Finch" in grid row 1 within ".site_info_window .staff_grid"}
    when "Bart Team"
      Then %{I should see "Staff - 0/2" within ".site_info_window .staff_grid"}
      Then %{I should see "Bartleby Scrivener" in grid row 2 within ".site_info_window .staff_grid"}
    when "Atticus & Bart"
      Then %{I should see "Staff - 0/2" within ".site_info_window .staff_grid"}
      Then %{I should see "Atticus Finch" in grid row 1 within ".site_info_window .staff_grid"}
      Then %{I should see "Bartleby Scrivener" in grid row 2 within ".site_info_window .staff_grid"}
  end
end

Then /^I should see role information for "([^\"]*)"$/ do |role_name|
  case role_name
    when "Chief Vet"
      Then %{I should see "Roles - 0/0/1" within ".site_info_window .roles_grid"}
      Then %{I should see "Chief Veterinarian" in grid row 1 within ".site_info_window .roles_grid"}
    when "Vet & BHD"
      Then %{I should see "Roles - 0/0/2" within ".site_info_window .roles_grid"}
      Then %{I should see "Border Health Director" within ".site_info_window .roles_grid"}
      Then %{I should see "Chief Veterinarian" within ".site_info_window .roles_grid"}
    when "Filled Vet"
      Then %{I should see "Roles - 0/1/1" within ".site_info_window .roles_grid"}
      Then %{I should see "Chief Veterinarian" in grid row 1 within ".site_info_window .roles_grid"}
    when "Filled Vet & BHD"
      Then %{I should see "Roles - 0/2/2" within ".site_info_window .roles_grid"}
      Then %{I should see "Border Health Director" within ".site_info_window .roles_grid"}
      Then %{I should see "Chief Veterinarian" within ".site_info_window .roles_grid"}
    when "Unfilled BHD"
      Then %{I should see "Roles - 0/0/1" within ".site_info_window .roles_grid"}
      Then %{I should see "Border Health Director" in grid row 1 within ".site_info_window .roles_grid"}
    when "Mixed Fill Vet & BHD"
      Then %{I should see "Roles - 0/1/2" within ".site_info_window .roles_grid"}
      Then %{I should see "Border Health Director" within ".site_info_window .roles_grid"}
      Then %{I should see "Chief Veterinarian" within ".site_info_window .roles_grid"}
  end
end

Then /^I should see inventory information for "([^\"]*)"$/ do |inventory_name|
  case inventory_name
    when "One Item"
      Then %{I should see "Item 1" in grid row 1 within ".site_info_window .inv_grid"}
    when "Many Items"
    Then %{the grid ".site_info_window .inv_grid" should contain:}, table(%{
      | Roles  |
      | Item 1 |
      | Item 2 |
    })
    when "Many Inventories"
      Then %{I should see "Item 1" in grid row 1 within ".site_info_window .inv_grid"}
      Then %{I should see "Item 1" in grid row 2 within ".site_info_window .inv_grid"}
    when "Out of Items"
      Then %{I should see "" within ".site_info_window .inv_grid .vms-site-info-item-danger"}
      Then %{the grid ".site_info_window .inv_grid" should contain:}, table(%{
      | Roles  |
      | Item 1 |
      | Item 2 |
    })
    when "Modified Many Inventories"
      Then %{I should see "Item 1" in grid row 1 within ".site_info_window .inv_grid"}
      Then %{I should see "11" in grid row 1 column 2 within ".site_info_window .inv_grid"}
      Then %{I should see "Item 1" in grid row 2 within ".site_info_window .inv_grid"}
  end
end

When /^I right click on the info window staff "([^\"]*)"$/ do |staff_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var siw = command_center.current_site_info_window;
    var i = siw.staffGrid.getStore().find('user', new RegExp('#{staff_name}'));
    var evt = { preventDefault: function(){}, getXY: function(){return [0,0];} } // make fake event to not break anything
    siw.showStaffContextMenu(siw.staffGrid, i, evt);
  ")
end

Then /^I should not see staff information for "([^\"]*)"$/ do |staff_name|
  case staff_name
    when "Just Atticus"
      Then %{I should see "Staff - 0/0" within ".site_info_window .staff_grid"}
      Then %{I should not see "Atticus Finch" in grid row 1 within ".site_info_window .staff_grid"}
  end
end

When /^I right click on the info window role "([^\"]*)"$/ do |role_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var siw = command_center.current_site_info_window;
    var i = siw.rolesGrid.getStore().find('role', new RegExp('#{role_name}'));
    var evt = { preventDefault: function(){}, getXY: function(){return [0,0];} } // make fake event to not break anything
    siw.showRoleContextMenu(siw.rolesGrid, i, evt);
  ")
end

Then /^I should not see role information for "([^\"]*)"$/ do |role_name| case role_name
    when "Chief Vet"
      Then %{I should see "Roles - 0/0/0" within ".site_info_window .roles_grid"}
      Then %{I should not see "Chief Veterinarian" in grid row 1 within ".site_info_window .roles_grid"}
  end
end

When /^I right click on the info window item "([^\"]*)"$/ do |item_name|
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var siw = command_center.current_site_info_window;
    var i = siw.itemsGrid.getStore().find('name', new RegExp('#{item_name}'));
    var evt = { preventDefault: function(){}, getXY: function(){return [0,0];} } // make fake event to not break anything
    siw.showInventoryContextMenu(siw.itemsGrid, i, evt);
  ")
end

When /^I close the open site info window$/ do
  page.execute_script("
    var command_center = Ext.getCmp(Ext.getBody().first().id).findComponent('vms_command_center');
    var siw = command_center.current_site_info_window;
    siw.close();
  ")
end