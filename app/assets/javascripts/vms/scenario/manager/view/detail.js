
Ext.ns('Talho.VMS.Scenario.Manager.View')

Talho.VMS.Scenario.Manager.View.Detail = Ext.extend(Ext.Panel, {
  autoscroll: true,
  padding: '5',
  initComponent: function(){
    this.user_rights = new Ext.util.MixedCollection();
    this.user_rights.addAll(this.record.get('user_rights'));
    var owner = this.user_rights.itemAt(this.user_rights.findIndex('permission_level', /^3$/));
    
    var item_list = [
      {xtype: 'box', html: this.record.get('name'), fieldLabel: 'Name', style: {'font-weight': 'bold', 'font-size': '1.5em'}},
      {xtype: 'box', html: this.record.get('state'), fieldLabel: 'Status'},
      {xtype: 'box', fieldLabel: 'Owner', html: owner['name'], cls: 'vms-scenario-detail-list'},
      {xtype: 'dataview', fieldLabel: 'Admins', store: new Ext.data.JsonStore({fields: ['id', 'name'], data: this.user_rights.filter('permission_level', /^2$/).getRange()}),
       tpl: new Ext.XTemplate('<tpl for="."><div>{name}</div></tpl>'), cls: 'vms-scenario-detail-list', emptyText: '&nbsp;', deferEmptyText: false
      },
      {xtype: 'dataview', fieldLabel: 'Readers', store: new Ext.data.JsonStore({fields: ['id', 'name'], data: this.user_rights.filter('permission_level', /^1$/).getRange()}),
       tpl: new Ext.XTemplate('<tpl for="."><div>{name}</div></tpl>'), cls: 'vms-scenario-detail-list', emptyText: '&nbsp;', deferEmptyText: false
      },
      {xtype: 'dataview', fieldLabel: 'Sites', store: new Ext.data.JsonStore({fields: ['id', {name: 'name', mapping: 'site.name'}], data: this.record.get('site_instances')}),
       tpl: new Ext.XTemplate('<tpl for="."><div>{name}</div></tpl>'), cls: 'vms-scenario-detail-list', emptyText: '&nbsp;', deferEmptyText: false
      }
    ];
    if(this.record.get('can_admin') === true){
      item_list.push({xtype: 'button', hideLabel: true, text: 'Edit Scenario Details', scope: this, handler: function(){this.fireEvent('edit', this.record);} });
    }
    
    this.items = [
      {xtype: 'container', padding: '5', layout: 'form', items: item_list}
    ]
    
    Talho.VMS.Scenario.Manager.View.Detail.superclass.initComponent.apply(this, arguments);
  }
});
