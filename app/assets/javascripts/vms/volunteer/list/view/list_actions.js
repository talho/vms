Ext.ns('Talho.VMS.Volunteer.List.View')

Talho.VMS.Volunteer.List.View.ListActions = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('list_click', 'status_check_click', 'alert_click');
    this.items = [
      {xtype: 'panel', margins: '5', itemId: 'body_panel', region: 'center', layout: 'anchor', items: [
        {xtype: 'actionbutton', text: 'Volunteer List', itemId: 'Volunteer List', anchor: '100%', scope: this, handler: function(){this.fireEvent('list_click')}, iconCls: 'vms-list-volunteers'},
        {xtype: 'actionbutton', text: 'Status Checks', itemId: 'Status Checks', anchor: '100%', scope: this, handler: function(){this.fireEvent('status_check_click')}, iconCls: 'vms-list-status-checks'},
        {xtype: 'actionbutton', text: 'Alert Volunteers', itemId: 'Alert', anchor: '100%', scope: this, handler: function(){this.fireEvent('alert_click')}, iconCls: 'vms-control-alert'}
      ]}
    ];
    
    Talho.VMS.Volunteer.List.View.ListActions.superclass.initComponent.apply(this, arguments);
    
    this.panel = this.getComponent('body_panel');
  },
  
  getCurrentAction: function(){
    var selectedIndex = this.panel.items.findIndex('selected', true)
    return selectedIndex < 0 ? null : this.panel.items.itemAt(selectedIndex).itemId;
  },
  
  setAction: function(action){
    var newSelection = this.panel.getComponent(action);
    if(newSelection && !newSelection.selected){
      this.panel.items.each(function(btn){
        if(btn.selected){
          btn.selected = false;
          btn.getEl().removeClass('vms-row-button-selected');
        }
      });
      newSelection.selected = true;
      newSelection.getEl().addClass('vms-row-button-selected');
    }
  }
});
