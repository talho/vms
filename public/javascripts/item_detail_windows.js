Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.ItemDetailWindow = Ext.extend(Ext.Window, {
  layout: 'form',
  height: 300,
  width: 400,
  modal: true,
  constructor: function(config){
    this.addEvents(
      /**
       * @event save
       * Fires when the save button is clicked. Override onSaveClicked to add more arguments.
       * @param {Window} this 
       */
      'save');
    this.masks = {};
    Ext.apply(config, {buttons: [{text: 'Save', scope: this, handler: this.onSaveClicked}, {text: 'Cancel', scope: this, handler: function(){this.close();} } ]});
    Talho.VMS.ux.ItemDetailWindow.superclass.constructor.apply(this, arguments);
  },
  
  /**
   * Override to provide arguments to event "save"
   */
  onSaveClicked: function(){
    this.fireEvent('save', this);
  },
  
  showMask: function(label){
    if(Ext.isEmpty(label)) label = 'Saving...';
    var mask = this.masks[label];
    if(!mask){
      this.masks[label] = new Ext.LoadMask(this.getLayoutTarget(), {msg: label});
    }
    this.current_mask = this.masks[label];
    this.current_mask.show();
    Ext.each(this.buttons, function(button){button.disable();});
  },
  
  hideMask: function(){
    if(this.current_mask) this.current_mask.hide();
    Ext.each(this.buttons, function(button){button.enable();});
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
        root: 'users',
        totalProperty: 'total',
        restful: true,
        fields: ['name', 'email', 'id', 'title', 'extra']
    });
    Ext.apply(config, {items: [{ xtype: 'combo', itemId: 'user', queryParam: 'tag',
        mode: 'remote', forceSelection: true, fieldLabel: 'Search for User',
        pageSize: 10,
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

Talho.VMS.ux.TeamWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  height: 400,
  constructor: function(config){
    Ext.apply(config, {items: [
      {xtype: 'textfield', fieldLabel: 'Team Name', itemId: 'name'},
      {xtype: 'label', hideLabel: true, text: 'Select Users:'},
      new Talho.ux.UserSelectionGrid({
        height: 350,
        itemId: 'users',
        hideLabel: true
      })
    ]});
    Talho.VMS.ux.TeamWindow.superclass.constructor.apply(this, arguments);
  },
  initComponent: function(){
    Talho.VMS.ux.TeamWindow.superclass.initComponent.apply(this, arguments);
    if(!Ext.isEmpty(this.record)){
      this.getComponent('name').setValue(this.record.get('status') === 'new' ?  'New Team' : this.record.get('name'));
      if(!Ext.isEmpty(this.record.users)){
        var store = this.getComponent('users').getStore();
        Ext.each(this.record.users, function(user){
          store.add(new (store.recordType)({name: user.get('name'), id: user.id}) );
        },this);
      }
    }
  },
  onSaveClicked: function(){
    this.fireEvent('save', this, this.getComponent('name').getValue(), this.getComponent('users').getStore().getRange())
  }
});
