
dominoes.property('vms', '/assets/vms');
dominoes.rule('VMS_Inventory', '$(vms)/inventory/inventory_controller.js $(ext_extensions)/xActionColumn.js ( $(vms)/item_detail_windows.js > $(vms)/inventory/create_and_edit.js )');
dominoes.rule('VMS_Site', '$(vms)/site/controller.js ( $(vms)/item_detail_windows.js > $(vms)/site/create_and_edit.js ) $(ext_extensions)/DoNotCollapseActive.js $(vms)/site/site_info_window.js ');
dominoes.rule('VMS_Roles', '$(ext_extensions)/xActionColumn.js $(vms)/roles/controller.js ( $(vms)/item_detail_windows.js > $(vms)/roles/create_and_edit.js )');
dominoes.rule('VMS_Staff', 'UserSelectionGrid $(vms)/staff/controller.js ( $(vms)/item_detail_windows.js > $(vms)/staff/create_and_edit.js )');
dominoes.rule('VMS_Teams', 'GroupSelectionGrid UserSelectionGrid $(vms)/teams/controller.js ( $(vms)/item_detail_windows.js > $(vms)/teams/create_and_edit.js )');
dominoes.rule('VMS_Qualifications', '$(vms)/qualifications/controller.js ( $(vms)/item_detail_windows.js > $(vms)/qualifications/create_and_edit.js )');
dominoes.rule('VMS_CommandCenter', '( $(vms)/command_center/context_menus.js $(vms)/command_center/site_applications.js $(vms)/command_center/scenario_status.js ) > $(vms)/command_center/command_center.js  $(vms)/extensions/action_button.js UserSelectionGrid $(vms)/scenario/status_change.js')
dominoes.rule('VMS_Scenario_Manager_Views', 'UserSelectionGrid $(vms)/extensions/action_button.js $(vms)/extensions/column_panel.js $(vms)/scenario/manager/view/list.js $(vms)/scenario/manager/view/edit_detail.js $(vms)/scenario/manager/view/edit_rights.js $(vms)/scenario/manager/view/detail.js $(vms)/scenario/manager/view/actions.js')
dominoes.rule('VMS_Scenario_Manager', 'VMS_Scenario_Manager_Views $(vms)/model/scenario.js $(vms)/scenario/manager/controller.js')
dominoes.rule('VMS_User_Qualifications', '$(vms)/model/qualification.js $(ext_extensions)/xActionColumn.js $(vms)/user/profile/view/qualifications.js')
dominoes.rule('VMS_User_Profile_Views', 'VMS_User_Qualifications $(vms)/extensions/column_panel.js $(vms)/user/profile/view/alerts.js $(vms)/extensions/action_button.js $(vms)/user/profile/view/alert_detail.js');
dominoes.rule('VMS_User_Profile', 'VMS_User_Profile_Views $(vms)/user/profile/controller.js $(vms)/model/alert.js');
dominoes.rule('VMS_Volunteer_List_Views', '$(vms)/extensions/column_panel.js > $(vms)/model/volunteer.js $(vms)/extensions/action_button.js $(vms)/volunteer/list/view/column_panel.js $(vms)/volunteer/list/view/list_actions.js $(vms)/volunteer/list/view/volunteer_list.js $(vms)/volunteer/list/view/alert.js $(vms)/volunteer/list/view/list.js $(vms)/volunteer/list/view/new_status_check.js $(vms)/volunteer/list/view/status_checks.js $(vms)/volunteer/list/view/status_responders.js $(vms)/volunteer/list/view/volunteer_actions.js VMS_User_Qualifications');
dominoes.rule('VMS_Volunteer_List', 'VMS_Volunteer_List_Views $(vms)/volunteer/list/controller.js');

Talho.ScriptManager.addInitializer('Talho.VMS.CommandCenter', {js:'GMap > $(ext_extensions)/DoNotCollapseActive.js VMS_Site VMS_Roles VMS_Inventory VMS_Staff VMS_Teams VMS_Qualifications VMS_CommandCenter'});
Talho.ScriptManager.addInitializer('Talho.VMS.CreateAndEditScenario', {js: 'UserSelectionGrid $(vms)/scenario/create_and_edit.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.ManageScenarios', {js: '$(ext_extensions)/xActionColumn.js $(vms)/scenario/manage_scenarios.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.Scenario.Manager', {js: 'GMap VMS_Scenario_Manager'});
Talho.ScriptManager.addInitializer('Talho.VMS.AdministerSites', {js: '$(ext_extensions)/xActionColumn.js $(vms)/site/administer_sites.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.User.Profile', {js: 'VMS_User_Profile'});
Talho.ScriptManager.addInitializer('Talho.VMS.Volunteer.List', {js: 'VMS_Volunteer_List'});