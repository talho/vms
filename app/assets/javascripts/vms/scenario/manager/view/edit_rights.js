Ext.ns("Talho.VMS.Scenario.Manager.View")

Talho.VMS.Scenario.Manager.View.EditRights = Ext.extend(Ext.Panel, {
  autoScroll: true,
  layout: 'fit',
  initComponent: function(){
    var combo_config = {mode: 'local', triggerAction: 'all', editable: false, store: [[1, 'Reader'], [2, 'Admin']]};
    if(Application.rails_environment == 'cucumber') combo_config['id'] = 'vms-scenario-permission-level-combo'
    
    this.items = [
      {title: 'Permissions', itemId: 'per', xtype: 'editorgrid', clicksToEdit: 1, border: true, enableColumnMove: false, enableHdMenu: false, enableColumnHide: false,
        viewConfig: {emptyText: '<h2><p>This scenario has not been shared with any other users. Please select users to share with in the Scenario Info tab.</p></h2>', deferEmptyText: false},
        store: new Ext.data.JsonStore({
          idProperty: 'id',
          fields: ['name', {name: 'permission_level', defaultValue: 1}, 'user_id', 'id']
        }),
        columns: [{header: 'User Name', dataIndex: 'name', editable: false, width: 150}, 
          {header: 'Permission Level', css: 'vms-permission-level', id: 'per', dataIndex: 'permission_level', renderer: function(value){switch(value){case 1: return 'Reader'; case 2: return 'Admin'; case 3: return 'Owner'; default: return '';}}, 
           editor: new Ext.form.ComboBox(combo_config)}
        ],
        autoExpandColumn: 'per',
        buttons: [
          {text: 'Save', scope: this, handler: this.save_click},
          {text: 'Cancel', scope: this, handler: function(){this.fireEvent('cancel');}}
        ] 
      }
    ];
    
    Talho.VMS.Scenario.Manager.View.EditDetail.superclass.initComponent.apply(this, arguments);
    
    this.permission_grid = this.getComponent('per');
    this.removed_records = [];
    
    if(this.record){ // we're editing so we need to load up the user rights, first let's remove the owner
      var user_rights = new Ext.util.MixedCollection();
      user_rights.addAll(this.record.get('user_rights'));
      this.permission_grid.getStore().loadData(user_rights.filter('permission_level', /^[12]$/).getRange());
    }
  },
  
  add_user: function(json){
    var store = this.permission_grid.getStore();
    store.add(new store.recordType(json));
  },
  
  remove_user: function(json){    
    var store = this.permission_grid.getStore();
    var i = store.find('user_id', new RegExp('^' + json.user_id + '$'));
    var rec = store.getAt(i);
    store.remove(rec);
    this.removed_records.push()
  },
  
  save_click: function(){
    var res = []
    
    this.permission_grid.getStore().each(function(r){
      var val = {user_id: r.get('user_id'), permission_level: r.get('permission_level')};
      if(!r.phantom) val['id'] = r.get('id');
      res.push(val);
    }, this);
    
    Ext.each(this.removed_records, function(r){
      if(!r.phantom) res.push({id: r.get('id'), _destroy: true});
    }, this)
    
    this.fireEvent('save', res, this.record);
  }
});
