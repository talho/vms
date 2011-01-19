Ext.ns("Talho.VMS");

Talho.VMS.OpenScenario = Ext.extend(Ext.Window, {
  title: 'Open Scenario',
  height: 300,
  constructor: function(config){
    Ext.apply(config, {
      items: [
        {xtype: 'grid', hideHeaders: true,
        store: new Ext.data.JsonStore({
          url: '/vms/scenarios',
          method: 'GET',
          fields: ['name', 'id'],
          autoLoad: true
        }),
        columns:[
          {dataIndex: 'name', id: 'name_column'}
        ], autoExpandColumn: 'name_column' }
      ],
      buttons:[
        {text: 'Open'},
        {text: 'Cancel', handler: function(){this.close();}, scope: this}
      ]
    });
    
    Talho.VMS.OpenScenario.superclass.constructor.apply(this, arguments);
  }
});


Talho.ScriptManager.reg('Talho.VMS.OpenScenario', Talho.VMS.OpenScenario, function(config){return new Talho.VMS.OpenScenario(config);});
