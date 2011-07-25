Ext.ns('Talho.VMS.Volunteer.List.View');

Talho.VMS.Volunteer.List.View.StatusResponders = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    var date_renderer = Ext.util.Format.dateRenderer('n/d/y, g:i A');
    
    this.items =  [
      {xtype: 'box', margins: '5', region: 'north', html: '<h1 style="text-align:center;">Volunteers</h1>'},
      {xtype: 'grid', margins: '5', region: 'center', store: new Ext.data.JsonStore({
          url: '/vms/alerts/' + this.record.get('id') + '.json',
          fields: ['id', {name: 'name', mapping: 'user.display_name'}, {name:'acknowledged', mapping: 'acknowledged_at', convert: function(val){return val === null ? false : true;} }, 'acknowledged_at'],
          autoLoad: true,
          root: 'alert_attempts'
        }),
        columns: [{header: 'Name', dataIndex: 'name', id: 'name_column'}, {header: 'Acknowledged', dataIndex: 'acknowledged', renderer:function(value){return value ? "Acknowledged" : "";}}, {header: 'At', dataIndex: 'acknowledged_at', renderer: date_renderer}],
        autoExpandColumn: 'name_column',
        loadMask: true
      }
    ];
    
    Talho.VMS.Volunteer.List.View.StatusResponders.superclass.initComponent.apply(this, arguments);
  }
});
