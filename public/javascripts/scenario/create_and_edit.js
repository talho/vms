Ext.ns("Talho.VMS")

Talho.VMS.CreateAndEditScenario = Ext.extend(Ext.Window, {
  title: 'Create Scenario',
  constructor: function(config){
    Ext.apply(config, {
      items:[{xtype: 'form', border: false, padding: '5', itemId: 'form_panel', items:[
        {xtype: 'textfield', fieldLabel: 'Scenario Name', name: 'scenario[name]'}
      ]}],
      buttons: [
        {text: 'Save', handler: this.save, scope: this},
        {text: 'Cancel', handler: function(){this.close();}, scope: this}
      ]
    });
    
    Talho.VMS.CreateAndEditScenario.superclass.constructor.apply(this, arguments);
  },
  
  save: function(){
    this.getComponent('form_panel').getForm().submit({
      scope: this,
      url: '/vms/scenarios',
      method: 'POST',
      success: function(){
        this.close();
      },
      failure: function(){
        Ext.Msg.alert('An error occurred while saving');
      }
    });
  }
});

Talho.ScriptManager.reg('Talho.VMS.CreateAndEditScenario', Talho.VMS.CreateAndEditScenario, function(config){return new Talho.VMS.CreateAndEditScenario(config);});
