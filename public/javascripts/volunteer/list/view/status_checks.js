Ext.ns('Talho.VMS.Volunteer.List.View');

Talho.VMS.Volunteer.List.View.StatusChecks = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('new_status_check', 'status_check_select');
    
    var date_renderer = Ext.util.Format.dateRenderer('n/d/y, g:i A');
    
    this.items = [
      {xtype: 'box', region: 'north', margins: '5', html: '<h1 style="text-align:center;">Status Checks</h1>'},
      {xtype: 'grid', itemId: 'grid', region: 'center', margins: '5', buttons: [
          {text: 'New Status Check', scope: this, handler: function(){this.fireEvent('new_status_check');}}
        ],
        store: new Ext.data.JsonStore({fields: ['id', {name:'date', mapping: 'created_at'}],
          url: '/vms/alerts/status_checks.json',
          root: 'status_checks',
          idProperty: 'id',
          autoLoad: true
        }),
        loadMask: true,
        columns: [{header: "Status Check Date", dataIndex: 'date', id: 'date', renderer: date_renderer}],
        autoExpandColumn: 'date',
        sm: new Ext.grid.RowSelectionModel({
          listeners: {
            scope: this,
            'rowselect': function(sm, i, r){this.fireEvent('status_check_select', r);}
          }
        })
      }
    ];
    
    Talho.VMS.Volunteer.List.View.StatusChecks.superclass.initComponent.apply(this, arguments);
  },

  reloadStatusChecks: function(){
    this.getComponent('grid').getStore().load();
  }
});
