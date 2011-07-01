Ext.ns("Talho.VMS.Scenario.Manager.View")

Talho.VMS.Scenario.Manager.View.EditDetail = Ext.extend(Ext.Panel, {
  padding: '5',
  layout: 'form',
  labelAlign: 'top',
  initComponent: function(){
    this.addEvents('useradd', 'userremove');
    
    this.items = [
      {xtype: 'textfield', itemId: 'name', fieldLabel: 'Name', anchor: '100%', allowBlank: false},
      {xtype: 'checkbox', itemId: 'template', boxLabel: 'Create as a Scenario Template', anchor: '100%', hideLabel: true},
      new Talho.ux.UserSelectionGrid({height: 205, anchor: '100%', itemId: 'users', fieldLabel: 'Users with read/admin rights for viewing the scenario command center', cls: 'user_selection_grid' })
    ];
    
    Talho.VMS.Scenario.Manager.View.EditDetail.superclass.initComponent.apply(this, arguments);
    
    this.user_selection_grid = this.getComponent('users');
    this.name_box = this.getComponent('name');
    this.template_box = this.getComponent('template');
    
    if(this.record){ // then we're in edit mode
      this.name_box.setValue(this.record.get('name'));
      this.template_box.hide();
      
      var user_rights = new Ext.util.MixedCollection();
      user_rights.addAll(this.record.get('user_rights'));
      user_rights = user_rights.filter('permission_level', /^[12]$/).getRange();
      var users = []
      Ext.each(user_rights, function(user){users.push({id: user.user_id, name: user.name, email: user.email})});
      this.user_selection_grid.getStore().loadData(users);
    }
    
    this.user_selection_grid.getStore().on({
      scope: this,
      'add': this.user_add,
      'remove': this.user_remove
    });
  },
  
  user_add: function(s, rs){
    this.fireEvent('useradd', rs);
  },
  
  user_remove: function(s, r){
    this.fireEvent('userremove', r);
  },
  
  getData: function(){
    return {
      name: this.name_box.getValue(),
      template: this.template_box.getValue()
    };
  }
});
