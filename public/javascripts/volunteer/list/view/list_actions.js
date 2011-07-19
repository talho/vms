Ext.ns('Talho.VMS.Volunteer.List.View')

Talho.VMS.Volunteer.List.View.ListActions = Ext.extend(Ext.Panel, {
  layout: 'anchor',
  initComponent: function(){
    this.addEvents('list_click', 'status_check_click', 'alert_click');
    this.items = [
      {xtype: 'actionbutton', text: 'Volunteer List', anchor: '100%', scope: this, handler: function(){this.fireEvent('list_click')}},
      {xtype: 'actionbutton', text: 'Status Checks', anchor: '100%', scope: this, handler: function(){this.fireEvent('status_check_click')}},
      {xtype: 'actionbutton', text: 'Alert Volunteers', anchor: '100%', scope: this, handler: function(){this.fireEvent('alert_click')}}
    ];
    
    Talho.VMS.Volunteer.List.View.ListActions.superclass.initComponent.apply(this, arguments);
  }
});
