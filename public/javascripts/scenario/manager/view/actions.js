Ext.ns('Talho.VMS.Scenario.Manager.View')

Talho.VMS.Scenario.Manager.View.Actions = Ext.extend(Ext.Panel, {
  initComponent: function(){
    this.addEvents('open_scenario', 'make_scenario', 'make_template', 'delete_scenario');
    
    var template = this.record.get('state') === 'Template';
    var can_admin = this.record.get('can_admin');
    this.items = [{xtype: 'actionbutton', text: template ? (can_admin === true ? 'Edit' : 'Open') + ' Template' : 'Open Scenario', scope: this, handler: function(){this.fireEvent('open_scenario', this.record);}, iconCls: 'vms-scenario-edit' }];
    
    if(can_admin === true){
      this.items.push(
        template ? {xtype: 'actionbutton', text: 'Launch Template as a New Scenario', scope: this, handler: this.make_scenario, iconCls: 'vms-scenario-copy'} : 
                   {xtype: 'actionbutton', text: 'Copy Scenario as Template', scope: this, handler: this.make_template, iconCls: 'vms-scenario-copy'}
      );
      this.items.push({xtype: 'actionbutton', text: 'Delete ' + (template ? 'Template' : 'Scenario'), scope: this, handler: function(){this.fireEvent('delete_scenario', this.record);}, iconCls: 'vms-scenario-delete' });
    }
    
    Talho.VMS.Scenario.Manager.View.Actions.superclass.initComponent.apply(this, arguments);
  },
  
  make_scenario: function(){
    this.fireEvent('make_scenario', this.record);
  },
  
  make_template: function(){
    this.fireEvent('make_template', this.record);
  }
});