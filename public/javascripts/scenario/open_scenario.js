Ext.ns("Talho.VMS");

Talho.VMS.OpenScenario = Ext.extend(Ext.Window, {
  title: 'Open Scenario',
  height: 300,
  width: 400,
  layout: 'fit',
  constructor: function(config){
    Ext.apply(config, {
      items: [
        {xtype: 'grid', itemId: 'grid_panel', loadMask: true, hideHeaders: true,
        store: new Ext.data.JsonStore({
          url: '/vms/scenarios',
          method: 'GET',
          root: 'scenarios',
          restful: true,
          idProperty: 'id',
          fields: ['name', 'id'],
          autoLoad: true,
          autoSave: false,
          writer: new Ext.data.JsonWriter({ })
        }),
        columns:[
          {dataIndex: 'name', id: 'name_column'},
          {xtype: 'xactioncolumn', tooltip: 'edit', icon: '/stylesheets/images/pencil.png', scope: this, handler: this.edit_click },
          {xtype: 'xactioncolumn', tooltip: 'delete', icon: '/stylesheets/images/cross-circle.png', scope: this, handler: this.delete_click }
        ], autoExpandColumn: 'name_column',
        sm: new Ext.grid.RowSelectionModel({singleSelect: true}) }
      ],
      buttons:[
        {text: 'Open', handler: this.open_scenario, scope: this},
        {text: 'Cancel', handler: function(){this.close();}, scope: this}
      ]
    });
    
    Talho.VMS.OpenScenario.superclass.constructor.apply(this, arguments);
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
    Application.fireEvent('openwindow', {title:'Modify ' + record.get('name'), scenarioId: record.get('id'), scenarioName: record.get('name'), initializer: 'Talho.VMS.CreateAndEditScenario'})
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


Talho.ScriptManager.reg('Talho.VMS.OpenScenario', Talho.VMS.OpenScenario, function(config){return new Talho.VMS.OpenScenario(config);});
