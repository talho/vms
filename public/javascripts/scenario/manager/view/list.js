Ext.ns('Talho.VMS.Scenario.Manager.View');

Talho.VMS.Scenario.Manager.View.List = Ext.extend(Ext.Panel, {
  padding: '5',
  layout: 'border',
  
  constructor: function(){
    this.addEvents('create', 'scenarioselected');
    Talho.VMS.Scenario.Manager.View.List.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function(){
    var store = Ext.extend(Ext.data.Store, {
      url: '/vms/scenarios.json',
      method: 'GET',
      restful: true,
      reader: new Ext.data.JsonReader({
        totalProperty: 'total',
        root: 'scenarios',
        idProperty: 'id',
        fields: Talho.VMS.Scenario.Model.Scenario
      }),
      autoLoad: true
    });
    
    var template_store = new store({
      baseParams: {
        'state[]': 1
      }
    });
    var active_store = new store({
      baseParams: {
        'state[]': [2,3,4]
      }
    });
    var completed_store = new store({
      baseParams: {
        'state[]': 5
      }
    });
    
    var date_renderer = Ext.util.Format.dateRenderer('n/d/y, H:i A');
    
    this.items = [
      {xtype: 'actionbutton', region: 'north', text: 'Create New Scenario', scope: this, handler: function(){this.fireEvent('create');}, iconCls: 'vms-scenario-create'},
      {xtype: 'container', layout: 'vbox', region: 'center', layoutConfig: {align: 'stretch', defaultMargins: '5'}, items: [
        {xtype: 'grid', title: 'Scenario Templates', flex: 1, loadMask: true, columns: [
            {dataIndex: 'name', id: 'name_column', header: 'Name'},
            {dataIndex: 'created_at', header: 'Created At', renderer: date_renderer},
            {dataIndex: 'updated_at', header: 'Last Updated At', renderer: date_renderer},
            {dataIndex: 'used_at', header: 'Last Used At', renderer: date_renderer}
          ], 
          store: template_store,
          sm: new Ext.grid.RowSelectionModel({single: true, listeners:{
            scope: this, 
            'rowselect': this.grid_rowselect
          }}),
          bbar: new Ext.PagingToolbar({pageSize: 10, store: template_store})
        },
        {xtype: 'grid', title: 'Active Scenarios', flex: 1, loadMask: true, columns: [
            {dataIndex: 'name', id: 'name_column', header: 'Name'},
            {dataIndex: 'state', header: 'Status'},
            {dataIndex: 'created_at', header: 'Created At', renderer: date_renderer},
            {dataIndex: 'updated_at', header: 'Last Updated At', renderer: date_renderer}
          ], 
          store: active_store , 
          sm: new Ext.grid.RowSelectionModel({single: true, listeners:{
            scope: this, 
            'rowselect': this.grid_rowselect
          }}),
          bbar: new Ext.PagingToolbar({pageSize: 10, store: active_store})
        },
        {xtype: 'grid', title: 'Completed Scenarios', flex: 1, loadMask: true, columns: [
            {dataIndex: 'name', id: 'name_column', header: 'Name'},
            {dataIndex: 'updated_at', header: 'Completed At', renderer: date_renderer}
          ], 
          store: completed_store, 
          sm: new Ext.grid.RowSelectionModel({single: true, listeners:{
            scope: this, 
            'rowselect': this.grid_rowselect
          }}),
          bbar: new Ext.PagingToolbar({pageSize: 10, store: completed_store})
        }
      ]}
    ];
    
    Talho.VMS.Scenario.Manager.View.List.superclass.initComponent.apply(this, arguments);
  },
  
  grid_rowselect: function(sm, i, r){
    Ext.each(this.findByType('grid'), function(grid){
      if(sm.grid !== grid){
        grid.getSelectionModel().clearSelections();
      }
    }, this);
    this.fireEvent('scenarioselected', r);
  },
  
  clearSelections: function(){
    Ext.each(this.findByType('grid'), function(grid){
      grid.getSelectionModel().clearSelections();
    }, this);
  },
  
  refreshGrids: function(){
    Ext.each(this.findByType('grid'), function(grid){
      grid.getStore().load();
    }, this);
  }
});
