Ext.ns("Talho.VMS");

Talho.VMS.AdministerSites = Ext.extend(Ext.Window, {
  title: 'Administer Sites',
  height: 300,
  width: 400,
  layout: 'fit',
  modal: true,
  constructor: function(config){
    Talho.VMS.AdministerSites.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function(){
    this.items = [
      {xtype: 'grid',
        itemId: 'grid_panel', loadMask: true, hideHeaders: false,
        viewConfig: { autoFill: true },
        store: new Ext.data.JsonStore({
          url: '/vms/user_active_sites', method: 'GET', restful: true,
          idProperty: 'id',
          fields: ['name', 'id', 'address', 'scenario'],
          autoLoad: true, autoSave: false,
          writer: new Ext.data.JsonWriter({ })
        }),
        columns:[
          {dataIndex: 'name', id: 'name_column', header: 'Site'},
          {dataIndex: 'scenario', id: 'scenario_column', header: 'Scenario'}
        ],
        sm: new Ext.grid.RowSelectionModel({
          singleSelect: true,
          listeners: { scope: this, 'rowselect': function(){ this.buttons[0].enable(); } }
        })
      }
    ];
    
    this.buttons = [
      {text: 'Launch Check-In Kiosk', itemId: 'launch_kiosk', handler: function(){ this.launch_kiosk(); }, scope: this, disabled: true},
      {text: 'Cancel', handler: function(){ this.close(); }, scope: this}
    ];
      
    Talho.VMS.AdministerSites.superclass.initComponent.apply(this, arguments);
  },
  
  launch_kiosk: function(){
    var scenario_site = this.getComponent('grid_panel').getSelectionModel().getSelected();
    if(scenario_site){
      Ext.Msg.confirm("Launch Check-In Kiosk?", "Launch the Check-In Kiosk for " + scenario_site.data.name  + "?  <br /> This will end your current PHIN session." , function(btn){
        if(btn === 'yes'){
          window.location = "/vms/kiosk/" + scenario_site.data.id;
        }
      }, this);
      Application.fireEvent('opentab', {title: 'Command Center - ' + scenario.get('name'), scenarioId: scenario.get('id'), scenarioName: scenario.get('name'), initializer: 'Talho.VMS.CommandCenter'});
    }
  }
});


Talho.ScriptManager.reg('Talho.VMS.AdministerSites', Talho.VMS.AdministerSites, function(config){return new Talho.VMS.AdministerSites(config);});
