Ext.ns('Talho.VMS.Volunteer.List.View');

Talho.VMS.Volunteer.List.View.NewStatusCheck = Ext.extend(Ext.Panel, {
  layout: 'border',
  cls: 'newStatusCheck',
  initComponent: function(){
    this.addEvents('submit_new_status_check', 'cancel');
    this.items =  [
      {xtype: 'box', margins: '5', region: 'north', html: '<h1 style="text-align:center;">Volunteers</h1>'},
      {xtype: 'volunteerlist', itemId: 'vol_list', margins: '5', region: 'center', chooseMode: true},
      {xtype: 'container', itemId: 'south', margins: '5', region: 'south', layout: 'anchor', items: [
        {xtype: 'box', html: '<h1 style="text-align:center;">Custom Message</h1>'},
        {xtype: 'textarea', itemId: 'custom_msg', name: 'custom_message', height: 150, anchor: '100%'},
        {xtype: 'container', layout: 'toolbar', buttonAlign: 'right', anchor: '100%', cls: 'x-panel-btns', items: [
          {xtype: 'button', text: 'Send Status Check Alert', scope: this, handler: this.send_status_check},
          {xtype: 'button', text: 'Cancel', scope: this, handler: function(){this.fireEvent('cancel');}}
        ]}
      ]}
    ];
        
    Talho.VMS.Volunteer.List.View.NewStatusCheck.superclass.initComponent.apply(this, arguments);
  },
  
  send_status_check: function(){
    // get the custom message
    var custom_message = this.getComponent('south').getComponent('custom_msg').getValue();
    // get the volunteer list
    var volunteers = this.getComponent('vol_list').getSelectionModel().getSelections();
    
    // fire submit event.
    this.fireEvent('submit_new_status_check', volunteers, custom_message);
  }
});
