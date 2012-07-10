//= require ext_extensions/xActionColumn

Ext.ns("Talho.VMS");

Talho.VMS.ManageScenarios = Ext.extend(Ext.Window, {
  title: 'Manage Scenarios',
  height: 300,
  width: 400,
  layout: 'fit',
  modal: true,
  constructor: function(config){
    Talho.VMS.ManageScenarios.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function(){
    this.items = [
      {xtype: 'grid', itemId: 'grid_panel', loadMask: true, hideHeaders: false,
      store: new Ext.data.JsonStore({
        url: '/vms/scenarios',
        method: 'GET',
        root: 'scenarios',
        restful: true,
        idProperty: 'id',
        fields: ['name', 'id', 'can_admin', 'is_owner', 'state'],
        autoLoad: true,
        autoSave: false,
        writer: new Ext.data.JsonWriter({ })
      }),
      columns:[
        {dataIndex: 'name', id: 'name_column', header: 'Name'},
        {dataIndex: 'state', header: 'Status', renderer: function(v){
          switch(v){
            case 1: return 'Template';
            case 2: return 'Unexecuted';
            case 3: return 'In Progress';
            case 4: return 'Paused';
            case 5: return 'Completed';
          }
        }},
        {xtype: 'xactioncolumn', tooltip: 'edit', icon: '/stylesheets/images/pencil.png', iconCls: 'edit', scope: this, handler: this.edit_click, showField: 'can_admin' },
        {xtype: 'xactioncolumn', tooltip: 'delete', icon: '/stylesheets/images/cross-circle.png', iconCls: 'delete', scope: this, handler: this.delete_click, showField: 'is_owner' }
      ], autoExpandColumn: 'name_column',
      sm: new Ext.grid.RowSelectionModel({singleSelect: true}) }
    ];
    
    this.buttons = [
      {text: 'Open', handler: this.open_scenario, scope: this},
      {text: 'Cancel', handler: function(){this.close();}, scope: this}
    ];
      
    Talho.VMS.ManageScenarios.superclass.initComponent.apply(this, arguments);
  },
  
  open_scenario: function(){
    var scenario = this.getComponent('grid_panel').getSelectionModel().getSelected();
    if(scenario){
      Application.fireEvent('opentab', {title: 'Command Center - ' + scenario.get('name'), scenarioId: scenario.get('id'), scenarioName: scenario.get('name'), initializer: 'Talho.VMS.CommandCenter'});
      this.close();
    }
  },
  
  /**
   * Opens the create and edit window with the configured record id and such.
   */
  edit_click: function(grid, row){
    var record = grid.getStore().getAt(row);
    Application.fireEvent('openwindow', {title:'Modify ' + record.get('name'), scenarioId: record.get('id'), scenarioName: record.get('name'), initializer: 'Talho.VMS.CreateAndEditScenario'});
    this.close();
  },
  
  /**
   * After a confirmation, sends an ajax request to the server to delete the selected item.
   * Reloads the open scenario grid
   */
  delete_click: function(grid, row){
    Ext.Msg.confirm('Delete Scenario', 'Are you sure you wish to delete ' + grid.getStore().getAt(row).get('name') + '? This action cannot be undone.', function(btn){
      if(btn == 'yes'){
        var store = grid.getStore();
        var record = store.getAt(row);
        store.remove(record);
        if(!grid.saveMask) grid.saveMask = new Ext.LoadMask(grid.getEl(), {msg: 'Saving...'});
        grid.saveMask.show();
        store.on('save', function(){
          grid.saveMask.hide();
        }, this, {single: true})
        store.save();
      }
    }, this);
  }
});


Talho.ScriptManager.reg('Talho.VMS.ManageScenarios', Talho.VMS.ManageScenarios, function(config){return new Talho.VMS.ManageScenarios(config);});
