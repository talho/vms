
dominoes.property('vms', '/javascripts/vms');
dominoes.rule('Inventory', '$(vms)/inventory/inventory_controller.js $(ext_extensions)/xActionColumn.js ( $(vms)/item_detail_windows.js > $(vms)/inventory/create_and_edit.js )');
dominoes.rule('Site', '$(vms)/site/controller.js ( $(vms)/item_detail_windows.js > $(vms)/site/create_and_edit.js )');

Talho.ScriptManager.addInitializer('Talho.VMS.CommandCenter', {js:'$(ext_extensions)/DoNotCollapseActive.js $(ext_extensions)/GMapPanel.js UserSelectionGrid Site Inventory $(vms)/item_detail_windows.js $(vms)/command_center.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.CreateAndEditScenario', {js: '$(vms)/scenario/create_and_edit.js'});
Talho.ScriptManager.addInitializer('Talho.VMS.OpenScenario', {js: '$(ext_extensions)/xActionColumn.js $(vms)/scenario/open_scenario.js'});
