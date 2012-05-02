Ext.ns("Talho.VMS.User.Profile.View")

Talho.VMS.User.Profile.View.AlertDetail = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('call_down_selected');
    
    this.items = [
      {xtype: 'box', region: 'north', margins: '5', html: '<h1 style="text-align:center;">' + this.record.get('name') + '</h1>'},
      {xtype: 'panel', region: 'center', margins: '5', padding: '5', items: [
        {xtype: 'component', cls: 'vms-alert-detail-message', html: this.record.get('message')}
      ]}
    ];
    
    if(!Ext.isEmpty(this.record.get('calldowns'))){
      var calldowns = [],
          calldown_response = this.record.get('call_down_response');
                
      Ext.each(this.record.get('calldowns'), function(calldown){
        calldowns.push({xtype: 'actionbutton', text: calldown['msg'], cls: (calldown['value'] == calldown_response) ? 'vms-call-down-selected-response' : '', iconCls: calldown['polarity'] == 'negative' ? 'vms-call-down-negative' : 'vms-call-down-positive', 
        scope: this, call_down_value: calldown['value'], handler: this.callDownButton_click});
      }, this);
      this.items.push(
        {xtype: 'panel', itemId: 'call_down_panel', cls: 'vms-alert-detail-call-downs', region: 'south', margins: '5', items: calldowns }
      );
    }
    else if(this.record.get('acknowledge') === true){
      this.items.push(
        {xtype: 'panel', itemId: 'call_down_panel', cls: 'vms-alert-detail-call-downs', region: 'south', margins: '5', items: [
          {xtype: 'actionbutton', text: 'Acknowledge', cls: (this.record.get('acknowledged_at') !== null) ? 'vms-call-down-selected-response' : '', iconCls: 'vms-call-down-positive', scope: this, handler: this.callDownButton_click, call_down_value: 1}
        ]}
      );
    }
      
    Talho.VMS.User.Profile.View.AlertDetail.superclass.initComponent.apply(this, arguments);
    
    this.call_down_panel = this.getComponent('call_down_panel');
  },
  
  callDownButton_click: function(btn){
    this.fireEvent('call_down_selected', this.record, btn.call_down_value)
  },
  
  setSelectedCallDown: function(val){
    // first find and remove any that are already marked as selected
    Ext.each(this.getEl().query('.vms-call-down-selected-response'), function(el){Ext.get(el).removeClass('vms-call-down-selected-response')});
    var selected_call_down = this.call_down_panel.items.find(function(btn){return btn.call_down_value == val;});
    if(selected_call_down) selected_call_down.addClass('vms-call-down-selected-response');
  }
});
