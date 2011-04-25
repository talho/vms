/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.CreateAndEditRoles = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  title: "Modify Roles",
  initComponent: function(){
    this.deleted_records = [];
    var start_editing = Ext.isDefined(this.creatingRecord),
        columns = [{dataIndex: 'role', id: 'role_name'}, 
          {xtype: 'xactioncolumn', icon: '/stylesheets/vms/images/list-remove-2.png', iconCls: 'decrease_count', handler: this.decrementQuantity, scope: this},
          {dataIndex: 'count', width: 20},
          {xtype: 'xactioncolumn', icon: '/stylesheets/vms/images/list-add-2.png', iconCls: 'increase_count', handler: this.incrementQuantity, scope: this},
          {xtype: 'xactioncolumn', icon: '/stylesheets/vms/images/action_delete.png', iconCls: 'remove_role', handler: this.removeRole, scope: this}
        ],
        body = [];
        
    if(this.readOnly){
      columns = [{dataIndex: 'role', id: 'role_name'}, 
        {dataIndex: 'count', width: 20}
      ];
    }
    else{
      body = [
        {xtype: 'button', itemId: 'new_role_button', text: 'Add New Role', anchor: '100%', hidden: start_editing, scope: this, handler: this.showAddNewRole},
        {xtype: 'panel', itemId: 'new_role_panel', cls: 'addRolePanel', layout: 'form', border: false, hidden: !start_editing, style: {
          'border': '1px solid',
          'border-color': '#FFFFFF #EDEDED #EDEDED'
        }, 
        buttons: [{text: 'Add Role', scope: this, handler: this.addRoleToGrid}, {text: 'Cancel', scope: this, handler: this.hideAddNewRole}], 
        items:[
          {xtype: 'combo', itemId: 'role_select_box', anchor: '100%', fieldLabel: 'Select Role', mode: 'local', triggerAction: 'all', store: new Ext.data.JsonStore({
            url: '/audiences/roles',
            autoLoad: true,
            idProperty: 'id',
            fields: [{name: 'name', mapping: 'name'}, {name: 'id', mapping: 'id'}],
            listeners: {
              scope: this,
              'load': function(store){
                if(this.creatingRecord && this.creatingRecord.get('status') !== 'new'){
                  var rec = store.getById(this.creatingRecord.get('role_id'));
                  this.role_select_box.setValue(rec.id);
                }
              }
            }
          }), displayField: 'name', valueField: 'id'}
        ]}
      ];
    }
    
    body.push({xtype: 'grid', itemId: 'role_grid', cls: 'modifyRoleGrid', border: false, autoHeight: true, 
        store: new Ext.data.JsonStore({ 
          pruneModifiedRecords: true,
          fields: ['role', {name: 'type', defaultValue: 'role'}, {name: 'status', defaultValue: 'active'}, 'id', 'site_id', 'site', 'role_id', {name: 'count', type: 'integer'}]
        }), 
        columns: columns, autoExpandColumn: 'role_name', hideHeaders: true
    })
    
    // Now create the grid and the stuff to add new rows
    this.layout = 'fit';
    this.items = [{xtype: 'panel', itemId: 'container_panel', border: false, autoScroll: true, layout: 'anchor', items: body }];
    
    if(this.readOnly){
      this.buttons = [{text: 'Close', scope: this, handler: function(){this.close();}}];
    }
    
    Talho.VMS.ux.CreateAndEditRoles.superclass.initComponent.apply(this, arguments);
    
    var container_panel = this.getComponent('container_panel');
    this.role_grid = container_panel.getComponent('role_grid');
    
    if(!this.readOnly){
      this.new_role_button = container_panel.getComponent('new_role_button');
      this.new_role_panel = container_panel.getComponent('new_role_panel');
      this.role_select_box = this.new_role_panel.getComponent('role_select_box');
    }
    else{
      this.setTitle('View Role Details');
    }
    
    this.on('afterrender', this.loadData, this, {delay: 1});
  },
  
  loadData: function(){
    this.showMask('Loading...');
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/roles.json',
      method: 'GET',
      callback: function(opts, success, resp){
        if(success){
          this.hideMask();
          var result = Ext.decode(resp.responseText);
          this.role_grid.getStore().loadData(result);
          this.loadSeededData();
          if(this.removedRecord){            
            var r = this.role_grid.getStore().getById(this.removedRecord.id);
            this.role_grid.getStore().remove(r);
            if(!r.phantom){ this.deleted_records.push(r); }
          }
        }
        else{
          Ext.Msg.alert('There was a problem loading the roles for this site');
          this.close();
        }
      },
      scope: this
    });
  },
  
  loadSeededData: function(){
    if(this.seededRolesCollection){
      var role_store = this.role_grid.getStore();
      this.seededRolesCollection.each(function(r){
        if(role_store.find('role_id', new RegExp('^' + r.get('role_id') + '$')) === -1){
          role_store.add(new role_store.recordType({role: r.get('name'), role_id: r.get('role_id'), count: r.get('count')}));
        }
      }, this);
    }
  },
  
  showAddNewRole: function(){
    this.new_role_button.hide();
    this.new_role_panel.show();
  },
  
  hideAddNewRole: function(){
    this.new_role_button.show();
    this.new_role_panel.hide();
    this.role_select_box.clearValue();
  },
  
  addRoleToGrid: function(){
    var id = this.role_select_box.getValue(),
        store = this.role_grid.getStore(), 
        role_index;
    this.hideAddNewRole();
    if(!id) return;
    
    // Check to see if the role is already in the grid
    var role_index = store.find('role_id', new RegExp('^' + id + '$'));
    if(role_index !== -1){
      this.role_grid.getSelectionModel().selectRow(role_index);
      return;
    }
    
    var name = this.role_select_box.getStore().getById(id).get('name');
    var store = this.role_grid.getStore();
    var rec = new store.recordType({role: name, role_id: id, count: 1, status: 'new' });
    rec.markDirty();
    store.insert(0, [rec]);
  },
  
  incrementQuantity: function(grid, row){
    var record = grid.getStore().getAt(row);
    record.set('count', record.get('count')*1 + 1);
  },
  
  decrementQuantity: function(grid, row){
    var record = grid.getStore().getAt(row);
    if(record.get('count')*1 > 1)
      record.set('count', record.get('count')*1 - 1);    
  },
  
  removeRole: function(grid, row){
    var r = grid.getStore().getAt(row);
    grid.getStore().removeAt(row);
    if(!r.phantom){ this.deleted_records.push(r); }
  },
  
  onSaveClicked: function(){
    var store = this.role_grid.getStore(),
      original_records = [],
      modified_records = this.role_grid.getStore().getModifiedRecords();
    
    this.fireEvent('save', this, modified_records, this.deleted_records);
  }
});