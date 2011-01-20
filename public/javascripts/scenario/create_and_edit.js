Ext.ns("Talho.VMS")

Talho.VMS.CreateAndEditScenario = Ext.extend(Ext.Window, {
  title: 'Create Scenario',
  modal: true,
  constructor: function(config){
    this.edit_mode = false;
    if(!Ext.isEmpty(config.scenarioId)){
      this.edit_mode = true;
    }
    
    if(this.edit_mode){
      var buttons = [
        {text: 'Save', handler: this.save, scope: this, mode: 'list'},
        {text: 'Save and Open Scenario', handler: this.save, scope: this},
        {text: 'Cancel', handler: function(){
          Application.fireEvent('openwindow', {id: 'vms_open_scenario', title:'Open Scenario', initializer: 'Talho.VMS.OpenScenario'});
          this.close();
        }, scope: this}
      ];
    }
    else{
      var buttons = [
        {text: 'Save', handler: this.save, scope: this},
        {text: 'Cancel', handler: function(){ this.close();}, scope: this}
      ];
    }
    
    Ext.apply(config, {
      items:[{xtype: 'form', border: false, padding: '5', itemId: 'form_panel', items:[
        {xtype: 'textfield', fieldLabel: 'Scenario Name', name: 'scenario[name]', value: this.edit_mode ? config.scenarioName : ''}
      ]}],
      buttons: buttons
    });
    
    Talho.VMS.CreateAndEditScenario.superclass.constructor.apply(this, arguments);
    
    this.on('afterrender', function(){this.getComponent('form_panel').getForm().waitMsgTarget = this.getLayoutTarget();}, this);
  },
  
  save: function(b){    
    this.getComponent('form_panel').getForm().submit({
      scope: this,
      waitMsg: 'Saving...',
      url: '/vms/scenarios' + (this.edit_mode ? '/' + this.scenarioId : ''),
      method: this.edit_mode ? 'PUT' : 'POST',
      success: function(form, action){
        if(b.mode == 'list'){
          Application.fireEvent('openwindow', {id: 'vms_open_scenario', title:'Open Scenario', initializer: 'Talho.VMS.OpenScenario'});
        }
        else{
          var scenario = action.result.scenario;
          Application.fireEvent('opentab', {title: 'Command Center - ' + scenario.name, scenarioId: scenario.id, scenarioName: scenario.name, initializer: 'Talho.VMS.CommandCenter'});
        }
        this.close();
      },
      failure: function(){
        Ext.Msg.alert('An error occurred while saving');
      }
    });
  }
});

Talho.ScriptManager.reg('Talho.VMS.CreateAndEditScenario', Talho.VMS.CreateAndEditScenario, function(config){return new Talho.VMS.CreateAndEditScenario(config);});
