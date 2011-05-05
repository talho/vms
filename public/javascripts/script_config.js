
dominoes.property('vms', '/javascripts/vms');
dominoes.rule('VMS_Inventory', '$(vms)/inventory/inventory_controller.js $(ext_extensions)/xActionColumn.js ( $(vms)/item_detail_windows.js > $(vms)/inventory/create_and_edit.js )');
dominoes.rule('VMS_Site', '$(vms)/site/controller.js ( $(vms)/item_detail_windows.js > $(vms)/site/create_and_edit.js ) $(ext_extensions)/DoNotCollapseActive.js $(vms)/site/site_info_window.js');
dominoes.rule('VMS_Roles', '$(ext_extensions)/xActionColumn.js $(vms)/roles/controller.js ( $(vms)/item_detail_windows.js > $(vms)/roles/create_and_edit.js )');
dominoes.rule('VMS_Staff', 'UserSelectionGrid $(vms)/staff/controller.js ( $(vms)/item_detail_windows.js > $(vms)/staff/create_and_edit.js )');
dominoes.rule('VMS_Teams', 'GroupSelectionGrid UserSelectionGrid $(vms)/teams/controller.js ( $(vms)/item_detail_windows.js > $(vms)/teams/create_and_edit.js )');
dominoes.rule('VMS_Qualifications', '$(vms)/qualifications/controller.js ( $(vms)/item_detail_windows.js > $(vms)/qualifications/create_and_edit.js )');
dominoes.rule('VMS_CommandCenter', '( $(vms)/command_center/context_menus.js $(vms)/command_center/site_applications.js ) > $(vms)/command_center/command_center.js UserSelectionGrid $(vms)/scenario/status_change.js')

Talho.ScriptManager.addInitializer('Talho.VMS.CommandCenter', {js:'$(ext_extensions)/DoNotCollapseActive.js GMap VMS_Site VMS_Roles VMS_Inventory VMS_Staff VMS_Teams VMS_Qualifications VMS_CommandCenter'});
Talho.ScriptManager.addInitializer('Talho.VMS.CreateAndEditScenario', {js: 'UserSelectionGrid $(vms)/scenario/create_and_edit.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.ManageScenarios', {js: '$(ext_extensions)/xActionColumn.js $(vms)/scenario/manage_scenarios.js'});
