/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.Scenario.Manager')

Talho.VMS.Scenario.Manager.Controller = Ext.extend(Ext.util.Observable, { 
  constructor: function(config){
    Ext.apply(this, config);
    Talho.VMS.Scenario.Manager.Controller.superclass.constructor.apply(this, arguments);
    
    this.current_selected = null;
    this.editing = false;
    
    // Initialize it with a new scenario list view
    this.columnPanel = new Talho.VMS.Scenario.Manager.View.ColumnLayout({});
    
    this.columnPanel.setColumn1(new Talho.VMS.Scenario.Manager.View.List({
      listeners: {
        scope: this,
        'create': this.scenario_create_edit,
        'scenarioselected': this.list_scenarioselected
      }
    }));
  },
  
  createNewScenario_click: function(){
    this.columnPanel.getColumn1().clearSelections();
    this.clearColumnPanel();
    this.columnPanel.setColumn2(new Talho.VMS.Scenario.Manager.View.EditDetail({
      listeners: {
        scope: this,
        'useradd': this.user_add,
        'userremove': this.user_remove
      }
    }));
    this.columnPanel.setColumn3(new Talho.VMS.Scenario.Manager.View.EditRights({
      listeners:{
        scope: this,
        'save': this.createNewScenario_save,
        'cancel': function(){
          this.columnPanel.getColumn1().clearSelections();
          this.clearColumnPanel();
        }
      }
    }));
  },
  
  clearColumnPanel: function(){
    this.editing = false;
    
    var c2 = this.columnPanel.getColumn2(),
        c3 = this.columnPanel.getColumn3();
        
    this.columnPanel.setColumn2(new Ext.BoxComponent({}));
    this.columnPanel.setColumn3(new Ext.BoxComponent({}));
    
    c2.purgeListeners();
    c3.purgeListeners();
    c2.destroy();
    c3.destroy();
  },
  
  list_scenarioselected: function(r){
    var make_detail = function(){
      this.clearColumnPanel();
      this.columnPanel.setColumn2(new Talho.VMS.Scenario.Manager.View.Detail({record: r, listeners:{
        scope: this,
        'edit': this.scenario_create_edit
      }}));
      this.columnPanel.setColumn3(new Talho.VMS.Scenario.Manager.View.Actions({record: r, listeners:{
        scope: this,
        'open_scenario': this.open_scenario,
        'delete_scenario': this.delete_scenario,
        'make_scenario': this.copy_scenario.createDelegate(this, [2], true),
        'make_template': this.copy_scenario.createDelegate(this, [1], true)
      }}));
    }.createDelegate(this);
    
    if(this.editing){
      Ext.Msg.confirm('Currently Editing', 'You are currently creating or editing a scenario. Continuing if you continue with this action, you will lose all changes. Would you like to continue?', function(btn){
        if(btn == 'yes'){
          make_detail();
        }
        else{
          this.columnPanel.getColumn1().clearSelections();
        }
      });
    }
    else{
      make_detail();
    }
  },
  
  scenario_create_edit: function(r){
    this.clearColumnPanel();
    this.editing = true;
    this.columnPanel.setColumn2(new Talho.VMS.Scenario.Manager.View.EditDetail({
      record: r,
      listeners: {
        scope: this,
        'useradd': this.user_add,
        'userremove': this.user_remove
      }
    }));
    this.columnPanel.setColumn3(new Talho.VMS.Scenario.Manager.View.EditRights({
      record: r,
      listeners:{
        scope: this,
        'save': this.scenario_save,
        'cancel': function(){
          this.columnPanel.getColumn1().clearSelections();
          this.clearColumnPanel();
        }
      }
    }));
  },
  
  scenario_save: function(permissions, record){
    var base_data = this.columnPanel.getColumn2().getData();
    
    // Do some validations here
    if(Ext.isEmpty(base_data['name'])){
      Ext.Msg.alert('Name is blank', 'A name for this scenario is required, please provide a name before saving.');
      return;
    }
    
    var params = {
      'scenario[name]': base_data['name'],
      'template': base_data['template']
    };
    Ext.each(permissions, function(ur, i){
      for(attr in ur){
       params['scenario[user_rights_attributes][' + i + '][' + attr + ']'] = ur[attr]; 
      }                  
    });
    
    var edit = !Ext.isEmpty(record);
    
    if(!this.saveMask) this.saveMask = new Ext.LoadMask(this.columnPanel.getEl(), {msg: 'Saving...'});
    this.saveMask.show();
    
    // Post or update to the server if we're creating or editing with the values we've got
    Ext.Ajax.request({
      url: '/vms/scenarios' + (edit ? '/' + record.get('id') : '') + '.json',
      method: edit ? 'PUT' : 'POST',
      params: params,
      scope: this,
      success: function(){
        this.saveMask.hide();
        this.columnPanel.getColumn1().clearSelections();
        this.columnPanel.getColumn1().refreshGrids();
        this.clearColumnPanel();
      },
      failure: function(){
        Ext.Msg.alert('Error', 'There was a problem saving this scenario');
        this.saveMask.hide();
      }
    });
  },
  
  user_add: function(rs){
    Ext.each(rs, function(r){
      this.columnPanel.getColumn3().add_user({name: r.get('name'), user_id: r.get('id'), permission_level: 1});
    }, this);
  },
  
  user_remove: function(r){
    this.columnPanel.getColumn3().remove_user({name: r.get('name'), user_id: r.get('id')});
  },
  
  open_scenario: function(scenario){
    Application.fireEvent('opentab', {title: 'Command Center - ' + scenario.get('name'), scenarioId: scenario.get('id'), scenarioName: scenario.get('name'), initializer: 'Talho.VMS.CommandCenter', id: 'scenario' + scenario.get('id')});
  },
  
  delete_scenario: function(scenario){
    Ext.Msg.confirm('Delete Scenario', 'Are you sure you wish to delete ' + scenario.get('name') + '? This action cannot be undone.', function(btn){
      if(btn == 'yes'){
        Ext.Ajax.request({
          url: '/vms/scenarios/' + scenario.get('id') + '.json',
          method: 'DELETE',
          scope: this,
          success: function(){
            this.columnPanel.getColumn1().refreshGrids();
            this.clearColumnPanel();
          }
        });
      }
    }, this);
  },
  
  copy_scenario: function(template, state){    
    if(!this.saveMask) this.saveMask = new Ext.LoadMask(this.columnPanel.getEl(), {msg: 'Saving...'});
    this.saveMask.show();
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + template.get('id') + '/copy.json',
      params: {
        state: state
      },
      method: 'POST',
      scope: this,
      success: function(response, options){
        var resp = Ext.decode(response.responseText);
        if(state === 2){ // if this is a new scenario copied off of the template
          var scenario = new Talho.VMS.Scenario.Model.Scenario(resp.scenario);
          this.open_scenario(scenario)
        }
        this.columnPanel.getColumn1().clearSelections();
        this.columnPanel.getColumn1().refreshGrids();
        this.clearColumnPanel();
      },
      callback: function(){
        this.saveMask.hide();
      }
    });
  }
});

Talho.ScriptManager.reg('Talho.VMS.Scenario.Manager', Talho.VMS.Scenario.Manager.Controller, function(config){
  var ctrl = new Talho.VMS.Scenario.Manager.Controller(config);
  return ctrl.columnPanel;
});