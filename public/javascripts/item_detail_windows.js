Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.ItemDetailWindow = Ext.extend(Ext.Window, {
  layout: 'form',
  
  constructor: function(config){
    this.addEvents(
      /**
       * @event save
       * Fires when the save button is clicked. Override onSaveClicked to add more arguments.
       * @param {Window} this 
       */
      'save');
    Ext.apply(config, {buttons: [{text: 'Save', scope: this, handler: this.onSaveClicked}, {text: 'Cancel', scope: this, handler: function(){this.close();} } ]});
    Talho.VMS.ux.ItemDetailWindow.superclass.constructor.apply(this, arguments);
  },
  
  /**
   * Override to provide arguments to event "save"
   */
  onSaveClicked: function(){
    this.fireEvent('save', this);
  }
});

Talho.VMS.ux.InventoryWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  constructor: function(config){
    Ext.apply(config, {items: [{xtype: 'textfield', itemId: 'name', fieldLabel: 'Inventory/POD name'},
      {xtype:'radiogroup', itemId: 'type', hideLabel: true, items: [{boxLabel: 'Inventory', checked: true, inputValue: 'inventory', name: 'type_radio_group'}, {boxLabel: 'POD', inputValue: 'pod', name: 'type_radio_group'}]}
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

Talho.VMS.ux.RoleWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  constructor: function(config){
    Ext.apply(config, {items: [{xtype: 'combo', fieldLabel: 'Select Role', itemId: 'role', mode: 'local', triggerAction: 'all', store: new Ext.data.JsonStore({
      url: '/audiences/roles',
      autoLoad: true,
      idProperty: 'id',
      fields: [
          {name: 'name', mapping: 'name'},
          {name: 'id', mapping: 'id'}
      ]
    }), displayField: 'name', valueField: 'name'}]});
    Talho.VMS.ux.RoleWindow.superclass.constructor.apply(this, arguments);
  },
  
  onSaveClicked: function(){
    this.fireEvent('save', this, this.getComponent('role').getValue());
  }
});

Talho.VMS.ux.UserWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  constructor: function(config){
    var json_store = new Ext.data.JsonStore({
        proxy: new Ext.data.HttpProxy({
            url: '/search/show_clean',
            api: {read: {url: '/search/show_clean', method:'POST'}}
        }),
        idProperty: 'id',
        bodyCssClass: 'users',
        restful: true,
        fields: ['name', 'email', 'id', 'title', 'extra']
    });
    Ext.apply(config, {items: [{ xtype: 'combo', itemId: 'user', queryParam: 'tag',
        mode: 'remote', forceSelection: true, fieldLabel: 'Search for User',
        store: json_store, displayField: 'name', name: 'User', valueField: 'name',
        tpl:'<tpl for="."><div ext:qtip=\'{extra}\' class="x-combo-list-item">{name} - {email}</div></tpl>',
        minChars: 2
    }]});
    Talho.VMS.ux.UserWindow.superclass.constructor.apply(this, arguments);
  },
  
  onSaveClicked: function(){
    this.fireEvent('save', this, this.getComponent('user').getValue());
  }
});
