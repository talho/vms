
Ext.ns("Talho.VMS.User.Profile.View");

Talho.VMS.User.Profile.View.Alerts = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('alert_selected');
    
    var tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div>{name}</div>',
        '<div>Scenario: {scenario_name}</div>',
        '<div>Author: {author}</div>',
        '<div>Created At: {[fm.date(values.created_at,\'n/d/y, g:i A\')]}</div>',
        '<tpl if="acknowledged_at!=null">',
          '<div>Acknowledged At: {[fm.date(values.acknowledged_at,\'n/d/y, g:i A\')]}</div>',
        '</tpl>',
      '</tpl>'
    );
    
    var store = new Ext.data.JsonStore({
      fields: Talho.VMS.Model.Alert,
      url: '/vms/alerts.json',
      autoLoad: true,
      restful: true,
      root: 'alerts'
    });
    
    this.items = [
      {xtype: 'box', html: '<h1 style="text-align:center;">Alerts</h1>', region: 'north', margins: '5'},
      {xtype: 'grid', cls: 'vms-alert-grid', hideHeaders: true, margins: '5', region: 'center', loadMask: true, store: store,
        columns: [{xtype: 'templatecolumn', id: 'col', tpl: tpl }],
        autoExpandColumn: 'col',
        sm: new Ext.grid.RowSelectionModel({singleSelect: true, listeners: {
          scope: this,
          'rowselect': this._alert_select
        }}),
        bbar: new Ext.PagingToolbar({pageSize: 10, store: store})
      }
    ]
    
    Talho.VMS.User.Profile.View.Alerts.superclass.initComponent.apply(this, arguments);
  },
  
  _alert_select: function(sm, row){
    var r = sm.grid.getStore().getAt(row);
    this.fireEvent('alert_selected', r);
  }
});
