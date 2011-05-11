/**
 * @author cdubose
 */
Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.ScenarioStatusChange = Ext.extend(Ext.Window, {
  modal: true,
  width: 375,
  height: 400,
  layout: 'fit',
  constructor: function(config){
    this.addEvents('response');
    
    Talho.VMS.ux.ScenarioStatusChange.superclass.constructor.apply(this, arguments);
    
    if(this.handler) this.on('response', this.handler, this.scope || this);
  },
  
  initComponent: function(){
    this.setTitle(this.titles[this.action]);
    
    if(this.action == 'alert'){
      this.buttons = [
        {text: 'OK', handler: this.responseSelected.createDelegate(this, ['ok'])},
        {text: 'Cancel', handler: this.responseSelected.createDelegate(this, ['cancel'])}
      ]
    }
    else {
      this.buttons = [
        {text: 'Yes', handler: this.responseSelected.createDelegate(this, ['yes'])},
        {text: 'No', handler: this.responseSelected.createDelegate(this, ['no'])}
      ]
    }
    
    if(this.action == 'execute'){
      this.items = [
        {xtype: 'box', html: this.text[this.action]}
      ];
    }
    else{
      this.items = {xtype: 'tabpanel', itemId: 'tp', activeItem: 0, items: [
        {title: 'Action Information', layout: 'form', itemId: 't1', labelAlign: 'top', padding: '5', items: [
          {xtype: 'box', html: this.text[this.action], hideLabel: true},
          {xtype: 'checkbox', hideLabel: true, itemId: 'custom_msg', boxLabel: 'Customize alert notification message', checked: this.action === 'alert' ? true : false, hidden: this.action === 'alert' ? true : false, scope: this, handler: this.customAlertChecked},
          {xtype: 'textarea', disabled: this.action === 'alert' ? false : true, itemId: 'alert_text', value: this.default_alert[this.action], anchor: '100%', height: 150, fieldLabel: 'Alert Message'}
        ]},
        {title: 'Alert Audience', layout: 'fit', itemId: 'aud', items: [
          new Talho.ux.UserSelectionGrid({
            itemId: 'users',
            cls: 'user_selection_grid'
          })
        ]}
      ]};
    }
    
    Talho.VMS.ux.ScenarioStatusChange.superclass.initComponent.apply(this, arguments);
    
    this.original_user_store = new Ext.data.JsonStore({
      fields: ['user', {name: 'type', defaultValue: 'manual_user'}, {name: 'status', defaultValue: 'active'}, 'id', 'site_id', 'site', 'user_id']
    });
    
    if(this.action !== 'execute'){
      Ext.Ajax.request({
        url: '/vms/scenarios/' + this.scenarioId + '/staff.json',
        method: 'GET',
        params: {
          with_detail: true
        },
        callback: function(opts, success, resp){
          if(success){
            var result = Ext.decode(resp.responseText);
            this.original_user_store.loadData(result);
            var users = [];
            Ext.each(result, function(r){
              users.push(r.user_detail);
            });
            this.getComponent('tp').getComponent('aud').getComponent('users').getStore().loadData(users);
          }
          else{
            Ext.Msg.alert('There was a problem loading the staff for this site');
            this.close();
          }
        },
        scope: this
      });
    }
  },
  
  customAlertChecked: function(cb, checked){
    this.getComponent('tp').getComponent('t1').getComponent('alert_text').setDisabled(!checked);
  },
  
  responseSelected: function(btn){
    var msg = null;
    if(this.action !== 'execute' && this.getComponent('tp').getComponent('t1').getComponent('custom_msg').checked){
      msg = this.getComponent('tp').getComponent('t1').getComponent('alert_text').getValue();
    }
    
    var users = null;
    if(this.action !== 'execute'){
      var removed = false,
        user_selection_store = this.getComponent('tp').getComponent('aud').getComponent('users').getStore();
        
      this.original_user_store.each(function(r){
        if(!user_selection_store.getById(r.get('user_id'))){
          removed = true;
          return false;
        }
      }, this);
      
      if(user_selection_store.getModifiedRecords().length > 0 || removed){
        users = [];
        user_selection_store.each(function(u){
          users.push(u.id);
        });
      }
    }
    this.fireEvent('response', btn, msg, users);
    this.close();
  },
  
  titles: {
    'execute': 'Execute Scenario',
    'pause': 'Pause Scenario Execution',
    'resume': 'Resume Scenario Execution',
    'stop': 'Stop Scenario Execution'
  },
  
  text: {
    'execute': "Are you sure that you wish to begin this scenario's execution?<br/>" +
               "Performing this action will fill unfilled roles with volunteers,<br/>" +
               "alert your staff of their assignments, and begin live updates<br/>" +
               "of the scenario map.",
    'pause': "The scenario execution will be paused. While it is paused, changes<br/>" +
             "that are made will not trigger alerts to be sent while the scenario is paused.<br/><br/>" +
             "Would you like to inform staff that the scenario is being paused?",
    'resume': 'The scenario will resume its execution.<br/><br/> Would you like to notify staff that the scenario has been resumed?',
    'stop': "The scenario execution will stopped. This indicates that the scenario is<br/>" +
            "completed. You will no long be able to modify this scenario. This action<br/>" +
            "cannot be undone. Are you sure you wish to end the scenario?",
    'alert': "Create your custom alert here."
  },
  
  default_alert: {
    'pause': "The scenario that you were participating in has been suspended. You may receive notification when this scenario has been resumed.",
    'resume': "The scenario that you have been participating in has resumed. Please reassume your normal duties.",
    'stop': "The scenario that you have been participating in has ended. Thank you for your participation.",
    'alert': ''
  }
});
