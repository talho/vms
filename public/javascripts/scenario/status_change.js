/**
 * @author cdubose
 */
Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.ScenarioStatusChange = Ext.extend(Ext.Window, {
  modal: true,
  constructor: function(config){
    this.addEvents('response');
    
    Talho.VMS.ux.ScenarioStatusChange.superclass.constructor.apply(this, arguments);
    
    if(this.handler) this.on('response', this.handler, this.scope || this);
  },
  
  initComponent: function(){
    this.setTitle(this.titles[this.action]);
    
    this.buttons = [
      {text: 'Yes', handler: this.responseSelected.createDelegate(this, ['yes'])},
      {text: 'No', handler: this.responseSelected.createDelegate(this, ['no'])}
    ]
    
    if(this.action == 'execute'){
      this.items = [
        {xtype: 'box', html: this.text[this.action]}
      ];
    }
    else{
      this.items = {xtype: 'tabpanel', itemId: 'tp', height: 300, width: 350, activeItem: 0, items: [
        {title: 'Action Information', layout: 'form', itemId: 't1', labelAlign: 'top', padding: '5', items: [
          {xtype: 'box', html: this.text[this.action], hideLabel: true},
          {xtype: 'checkbox', hideLabel: true, itemId: 'custom_msg', boxLabel: 'Customize alert notification message', checked: false, scope: this, handler: this.customAlertChecked},
          {xtype: 'textarea', disabled: true, itemId: 'alert_text', value: this.default_alert[this.action], anchor: '100%', height: 150, fieldLabel: 'Alert Message'}
        ]},
        {title: 'Alert Audience', layout: 'fit', items: [
          new Talho.ux.UserSelectionGrid({
            itemId: 'users',
            cls: 'user_selection_grid'
          })
        ]}
      ]};
    }
    
    Talho.VMS.ux.ScenarioStatusChange.superclass.initComponent.apply(this, arguments);
  },
  
  customAlertChecked: function(cb, checked){
    this.getComponent('tp').getComponent('t1').getComponent('alert_text').setDisabled(!checked);
  },
  
  responseSelected: function(btn){
    var msg = null;
    if(this.action !== 'execute' && this.getComponent('tp').getComponent('t1').getComponent('custom_msg').checked){
      msg = this.getComponent('tp').getComponent('t1').getComponent('alert_text').getValue();
    }
    this.fireEvent('response', btn, msg);
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
            "cannot be undone. Are you sure you wish to end the scenario?"
  },
  
  default_alert: {
    'pause': "The scenario that you were participating in has been suspended. You will may receive notification when this scenario has been resumed.",
    'resume': "The scenario that you have been participating in has resumed. Please reassume your normal duties.",
    'stop': "The scenario that you have been participating in has ended. Thank you for your participation."
  }
});
