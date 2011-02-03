Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.InventoryWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  constructor: function(config){
    Ext.apply(config, {
      items: [
        {xtype: 'textfield', itemId: 'name', fieldLabel: 'Inventory/POD name'},
        {xtype:'radiogroup', itemId: 'type', hideLabel: true, items: [{boxLabel: 'Inventory', checked: true, inputValue: 'inventory', name: 'inventory_type'}, {boxLabel: 'POD', inputValue: 'pod', name: 'inventory_type'}]}
    ]});
    
    Talho.VMS.ux.InventoryWindow.superclass.constructor.call(this, config);
  },
  
  initComponent: function(){
    Talho.VMS.ux.InventoryWindow.superclass.initComponent.apply(this, arguments);
    if(!Ext.isEmpty(this.record)){
      var status = this.record.get('status');
      this.getComponent('name').setValue(status == 'new' ? ('New Inventory') : status == 'active' ? ('Copy of ' + this.record.get('name') ) : this.record.get('name') );
      if(this.record.get('type') == 'pod'){
        this.getComponent('type').items[0].checked = false;
        this.getComponent('type').items[1].checked = true;
      }
    }
  },
  onSaveClicked: function(){
    this.fireEvent('save', this, this.getComponent('name').getValue(), this.getComponent('type').getValue().getRawValue());
  }
});