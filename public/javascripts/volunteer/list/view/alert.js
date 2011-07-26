Ext.ns('Talho.VMS.Volunteer.List.View');

Talho.VMS.Volunteer.List.View.Alert = Ext.extend(Ext.Panel, {
  layout: 'border',
  cls: "customAlertPanel",
  initComponent: function(){
    this.addEvents('send_alert');
    
    this.items = [
      {xtype: 'box', region: 'north', margins: '5', html: '<h1 style="text-align:center;">Custom Alert</h1>'},
      {xtype: 'container', itemId: 'center_form', layout: 'form', region: 'center', margins: '5', labelAlign: 'top', items:[
        {xtype: 'textfield', itemId: 'title', anchor: '100%', fieldLabel: 'Title'},
        {xtype: 'textarea', itemId: 'message', anchor: '100%', height: 200, fieldLabel: 'Message'}
      ]},
      {xtype: 'container', layout: 'toolbar', buttonAlign: 'right', region: 'south', margins: '10', items: [
        {xtype: 'button', text: 'Send Alert', anchor: '0', scope: this, handler: this.send_alert}
      ]}
    ];
    
    Talho.VMS.Volunteer.List.View.Alert.superclass.initComponent.apply(this, arguments);
    
    this.message = this.getComponent('center_form').getComponent('message');
    this.title = this.getComponent('center_form').getComponent('title');
  },
  
  send_alert: function(){
    this.fireEvent('send_alert', this.title.getValue(), this.message.getValue());
  }
});
