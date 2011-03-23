/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux')

Talho.VMS.ux.CreateAndEditTeam = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  layout: 'border',
  initComponent: function(){
    this.items = [
      { 
        itemId: 'npanel',
        region: 'north',
        layout: 'form',
        height: 45,
        items:[
          {xtype: 'textfield', fieldLabel: 'Team Name', itemId: 'name'},
          {xtype: 'label', hideLabel: true, text: 'Select Users:'}
      ]},
      new Talho.ux.UserSelectionGrid({
        region: 'center',
        itemId: 'users',
        cls: 'user_selection_grid',
        hideLabel: true
      })
    ]
    if(this.mode !== 'edit'){
      this.items.push({xtype: 'checkbox', itemId: 'template', region: 'south', boxLabel: 'Save as template', hideLabel: true});
    }
    
    if(this.mode !== 'edit'){
      this.fbar = {
        buttonAlign: 'left',
        items: Ext.flatten([{xtype: 'button', text: 'Import Team', handler: this.onImportTeamClicked, scope: this}, '->', this.buttons])
      };
      this.buttons = null;
    }
    
    Talho.VMS.ux.CreateAndEditTeam.superclass.initComponent.apply(this, arguments);
        
    this.userGrid = this.getComponent('users');
    this.nameField = this.getComponent('npanel').getComponent('name');
    this.templateField = this.getComponent('template');
    
    if(!Ext.isEmpty(this.record)){
      this.nameField.setValue(this.record.get('status') === 'new' ?  'New Team' : this.record.get('name'));
      if(!Ext.isEmpty(this.record.users)){
        var store = this.userGrid.getStore();
        Ext.each(this.record.users, function(user){
          store.add(new (store.recordType)({name: user.get('name'), id: user.id}) );
        },this);
      }
    }
    
    if(this.mode === 'edit'){
      this.loadData();
      this.on('afterrender', function(){
        this.showMask('Loading...');
      }, this, {delay: 1});
      this.setTitle('Modify Team');
    }
    else{
      this.setTitle('Create Team');
    }
  },
  
  loadData: function(){
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/teams/' + this.creatingRecord.id + '/edit',
      method: 'GET',
      callback: function(options, success, response){
        this.hideMask();
        
        if(success){
          var resp = Ext.decode(response.responseText);
          this.userGrid.getStore().loadData(resp.users);
          this.nameField.setValue(resp.name);
        }
      },
      scope: this
    });
  },
  
  onImportTeamClicked: function(){
    var userStore = new Ext.data.JsonStore({
      fields: ['name', 'id', 'email', 'title', 'tip', 'type'],
      proxy: new Ext.data.HttpProxy({ url: '/audiences/recipients.json', method: 'GET' }),
      autoLoad: false
    });
    
    var win = new Ext.Window({
      title: 'Select Group',
      layout: 'hbox',
      cls: 'import_group_window',
      layoutConfig: {align: 'stretch'},
      width: 300,
      height: 400,
      items: [{xtype: 'grid', title: 'Groups', itemId: 'group_grid', cls: 'vms_group_import_selection_grid', flex:1, bodyCssClass: 'groups', autoExpandColumn: 'name_column',
        columns:[{id:'name_column', header:'Name', dataIndex:'name'}, {header: 'Group Type', dataIndex:'grouptype', hidden:true, groupRenderer: Ext.util.Format.capitalize, groupable: true}],
        store: new Ext.data.GroupingStore({
            url: '/audiences/groups',
            reader: new Ext.data.JsonReader({ idProperty: 'id', fields: ['name', 'id', {name: 'grouptype', mapping:'scope', convert:function(v, record){ switch(v){ 
              case 'Organization': return 'Organization'; 
              case 'Team': return 'Team'; 
              default: return 'Group';} 
            }}] }),
            groupField: 'grouptype', autoSave: false, autoLoad: true,
            sortInfo:{ field: 'grouptype', direction: 'ASC' }
        }),
        sm: new Ext.grid.RowSelectionModel({
          listeners: {
            scope: this,
            'rowselect': function(sm, i, r){
              userStore.load({params: {audience_id: r.get('id')} });
            }
          }
        }),
        loadMask: true, hideHeaders: true,
        view: new Ext.grid.GroupingView({
            groupTextTpl: '{group}s',
            enableGroupingMenu: false
        }),
      }, {xtype: 'grid', itemId: 'user_grid', cls: 'vms_import_teams_preview', title: 'Users', flex:1, autoExpandColumn: 'name_column', loadMask: true, hideHeaders: true,
        columns: [{id:'name_column', dataIndex: 'name'}],
        plugins: [new Ext.ux.DataTip({tpl:'<tpl for="."><div>{tip}</div></tpl>'})],
        store: userStore
      }],
      buttons: [{text: 'Import', scope: this, handler: function(){
        var user_grid = win.getComponent('user_grid');
        this.selected_group = win.getComponent('group_grid').getSelectionModel().getSelected();
        this.nameField.setValue(this.selected_group.get('name'));
        this.userGrid.getStore().removeAll();
        this.userGrid.getStore().add(user_grid.getStore().getRange());
        win.close();
      }}, {text: 'Cancel', handler: function(){win.close();}}]
    });
    
    win.show();
  }, 
  
  onSaveClicked: function(){
    var user_ids = this.userGrid.getStore().collect('id');
    if(this.mode == 'edit'){
      this.fireEvent('save', this, this.creatingRecord.id, this.nameField.getValue(), user_ids);
    }
    else{
      this.fireEvent('save', this, this.nameField.getValue(), this.templateField? this.templateField.checked : false, user_ids, this.selected_group ? this.selected_group.id : null);
    }
  }
});
