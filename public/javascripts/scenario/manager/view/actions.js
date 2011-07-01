Ext.ns('Talho.VMS.Scenario.Manager.View')

Talho.VMS.Scenario.Manager.View.Actions = Ext.extend(Ext.Panel, {
  initComponent: function(){
    this.addEvents('open_scenario', 'make_scenario', 'make_template', 'delete_scenario');
    
    var template = this.record.get('state') === 'Template';
    this.items = [
      {xtype: 'actionbutton', text: template ? 'Edit Template' : 'Open Scenario', scope: this, handler: function(){this.fireEvent('open_scenario', this.record);}, iconCls: 'vms-scenario-edit' },
      template ? {xtype: 'actionbutton', text: 'Launch Template as a New Scenario', scope: this, handler: this.make_scenario, iconCls: 'vms-scenario-copy'} : 
                 {xtype: 'actionbutton', text: 'Copy Scenario as Template', scope: this, handler: this.make_template, iconCls: 'vms-scenario-copy'},
      {xtype: 'actionbutton', text: 'Delete ' + (template ? 'Template' : 'Scenario'), scope: this, handler: function(){this.fireEvent('delete_scenario', this.record);}, iconCls: 'vms-scenario-delete' }
    ]
    
    Talho.VMS.Scenario.Manager.View.Actions.superclass.initComponent.apply(this, arguments);
  },
  
  make_scenario: function(){
    this.fireEvent('make_scenario', this.record);
  },
  
  make_template: function(){
    this.fireEvent('make_template', this.record);
  }
});