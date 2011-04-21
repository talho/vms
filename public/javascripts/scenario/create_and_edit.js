Ext.ns("Talho.VMS")

Talho.VMS.CreateAndEditScenario = Ext.extend(Ext.Window, {
  title: 'Create Scenario',
  modal: true,
  height: 350,
  layout: 'fit',
  width: 400,
  constructor: function(config){
    this.edit_mode = false;
    if(!Ext.isEmpty(config.scenarioId)){
      this.edit_mode = true;
    }
    
    Talho.VMS.CreateAndEditScenario.superclass.constructor.apply(this, arguments);
  },
  
  initComponent: function(){
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
    
    this.items = {xtype: 'tabpanel', itemId: 'tab_panel', activeItem: 0, border: false, items: [
      {xtype: 'form', title: "Scenario Info", border: false, padding: '5', itemId: 'form_panel', items:[
        {xtype: 'textfield', fieldLabel: 'Scenario Name', name: 'scenario[name]', value: this.edit_mode ? this.scenarioName : '', anchor: '100%'},
        {xtype: 'label', hideLabel: true, text: 'Select Scenario Managers:', cls: 'x-form-item'},
        new Talho.ux.UserSelectionGrid({height: 205, anchor: '100%', itemId: 'users', hideLabel: true, cls: 'user_selection_grid', listeners:{scope: this}})
      ]},
      {title: 'Permissions', itemId: 'per', padding: '5', autoScroll: true, items:[
          {itemId: 'perempty', xtype: 'box', html: 'This scenario is not shared with any individual users. You can select users on the Scenario Info tab'},
          {itemId: 'perholder', xtype: 'form', border: false, hidden: true, autoScroll: true}
        ], listeners:{
          scope: this,
          'show': this.fillPermissionsForm
      }}
    ]};
    this.buttons = buttons;
    
    Talho.VMS.CreateAndEditScenario.superclass.initComponent.apply(this, arguments);
    
    this.on('afterrender', function(){this.getComponent('tab_panel').getComponent('form_panel').getForm().waitMsgTarget = this.getLayoutTarget();}, this);
  },
  
  save: function(b){    
    this.getComponent('tab_panel').getComponent('form_panel').getForm().submit({
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
  },
  
  fillPermissionsForm: function(){
        var user_store = this.getComponent('tab_panel').getComponent('form_panel').getComponent('users').getStore();
        var users = user_store.getRange();
        var per_form = this.getComponent('tab_panel').getComponent('per').getComponent('perholder');

        if(Ext.isEmpty(users)){
          this.getComponent('tab_panel').getComponent('per').getComponent('perempty').show();
          per_form.hide();
          return;
        }

        // get values
        var vals = new Ext.util.MixedCollection();
        try
        {
            var gval_results = [];
            if(per_form.rendered)
                gval_results = per_form.getForm().getValues();
            else
                gval_results =  this.loaded_data;

            for(var k in gval_results){
                if(k.match(/scenario\[permissions\]\[\d+\]\[user_id\]/) !== null){
                    var index = k.match(/\d+/)[0];
                    var p = gval_results['scenario[permissions][' + index + '][permission]'];
                    var u = gval_results[k];
                    vals.add({user_id: u, permission: p});
                }
            }
        }
        catch(e){

        }

        // clear form
        per_form.removeAll(true);

        this.getComponent('tab_panel').getComponent('per').getComponent('perempty').hide();
        
        Ext.each(users, function(user, index){
            var v_index = vals.findIndex('user_id', user.get('id'));
            var val = v_index != -1 ? vals.get(v_index).permission : 0;
            per_form.add([
                {xtype: 'combo', mode: 'local', triggerAction: 'all', editable: false, fieldLabel: user.get('name'), hiddenName: 'scenario[permissions][' + index + '][permission]', store: [[0, 'Reader'], [1, 'Admin']], value: val},
                {xtype: 'hidden', name: 'scenario[permissions][' + index + '][user_id]', value: user.get('id')}
            ]);
        }, this);
        
        per_form.show();
        // make sure it lays out
        this.doLayout();
    }
});

Talho.ScriptManager.reg('Talho.VMS.CreateAndEditScenario', Talho.VMS.CreateAndEditScenario, function(config){return new Talho.VMS.CreateAndEditScenario(config);});
