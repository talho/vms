Ext.ns("Talho.VMS")

Talho.VMS.CreateAndEditScenario = Ext.extend(Ext.Window, {
  title: 'Create Scenario',
  modal: true,
  height: 350,
  layout: 'fit',
  width: 400,
  constructor: function(config){
    this.edit_mode = false;
    if(!Ext.isEmpty(config.scenarioId)){
      this.edit_mode = true;
    }
    this.masks = {};
    Talho.VMS.CreateAndEditScenario.superclass.constructor.apply(this, arguments);
    this.removed_records = [];
  },
  
  initComponent: function(){
    if(this.edit_mode){
      var buttons = [
        {text: 'Save', handler: this.save, scope: this, mode: 'list'},
        {text: 'Save and Open Scenario', handler: this.save, scope: this},
        {text: 'Cancel', handler: function(){
          Application.fireEvent('openwindow', {id: 'vms_open_scenario', title:'Open Scenario', initializer: 'Talho.VMS.OpenScenario'});
          this.close();
        }, scope: this}
      ];
    }
    else{
      var buttons = [
        {text: 'Save', handler: this.save, scope: this},
        {text: 'Cancel', handler: function(){ this.close();}, scope: this}
      ];
    }
    
    this.items = {xtype: 'tabpanel', itemId: 'tab_panel', activeItem: 0, border: false, items: [
      {xtype: 'form', title: "Scenario Info", border: false, padding: '5', itemId: 'form_panel', items:[
        {xtype: 'textfield', fieldLabel: 'Scenario Name', name: 'scenario[name]', value: this.edit_mode ? this.scenarioName : '', anchor: '100%'},
        {xtype: 'label', hideLabel: true, text: 'Select Scenario Managers:', cls: 'x-form-item'},
        new Talho.ux.UserSelectionGrid({height: 205, anchor: '100%', itemId: 'users', hideLabel: true, cls: 'user_selection_grid'})
      ]},
      {title: 'Permissions', itemId: 'per', xtype: 'editorgrid', clicksToEdit: 1, border: false, enableColumnMove: false, enableHdMenu: false, enableColumnHide: false,
        viewConfig: {emptyText: '<h2><p>This scenario has not been shared with any other users. Please select users to share with in the Scenario Info tab.</p></h2>', deferEmptyText: false},
        store: new Ext.data.JsonStore({
          fields: ['name', {name: 'permission_level', defaultValue: 1}, 'user_id']
        }),
        columns: [{header: 'User Name', dataIndex: 'name', editable: false}, 
          {header: 'Permission Level', id: 'per', dataIndex: 'permission_level', renderer: function(value){switch(value){case 1: return 'Reader'; case 2: return 'Admin'; case 3: return 'Owner'; default: return '';}}, 
           editor: new Ext.form.ComboBox({mode: 'local', triggerAction: 'all', editable: false, store: [[1, 'Reader'], [2, 'Admin']]})}
        ],
        autoExpandColumn: 'per' 
      }
    ]};
    this.buttons = buttons;
    
    Talho.VMS.CreateAndEditScenario.superclass.initComponent.apply(this, arguments);
    
    this.main_form = this.getComponent('tab_panel').getComponent('form_panel');
    this.selection_grid = this.main_form.getComponent('users');
    this.permission_grid = this.getComponent('tab_panel').getComponent('per');
        
    this.selection_grid.getStore().on({
      scope: this,
      'add': this.userAdded,
      'remove': this.userRemoved
    });
    
    if(this.edit_mode){
      this.on('afterrender', function(){this.showMask("Loading...");}, this, {delay: 1});
      Ext.Ajax.request({
        url: '/vms/scenarios/' + this.scenarioId + '/edit.json',
        method: 'GET',
        scope: this,
        callback: this.loadComplete
      });
    }
  },
  
  loadComplete: function(opts, success, response){
    this.hideMask();
    var resp_obj = Ext.decode(response.responseText);
    
    this.permission_grid.getStore().loadData(resp_obj.user_rights);
    
    var users = resp_obj.user_rights;
    Ext.each(users, function(user){user.id = user.user_id});
    var user_selection_store = this.selection_grid.getStore();
    
    user_selection_store.loadData(users);
  },
  
  save: function(b){    
    this.showMask();
    this.main_form.getForm().submit({
      scope: this,
      url: '/vms/scenarios' + (this.edit_mode ? '/' + this.scenarioId : ''),
      method: this.edit_mode ? 'PUT' : 'POST',
      success: function(form, action){
        this.hideMask();
        if(b.mode == 'list'){
          Application.fireEvent('openwindow', {id: 'vms_open_scenario', title:'Open Scenario', initializer: 'Talho.VMS.OpenScenario'});
        }
        else{
          var scenario = action.result.scenario;
          Application.fireEvent('opentab', {title: 'Command Center - ' + scenario.name, scenarioId: scenario.id, scenarioName: scenario.name, initializer: 'Talho.VMS.CommandCenter'});
        }
        this.close();
      },
      failure: function(){
        Ext.Msg.alert('An error occurred while saving');
      }
    });
  },
  
  userAdded: function(store, records){
    var store = this.permission_grid.getStore();
    
    Ext.each(records, function(r){
      store.add(new store.recordType({name: r.get('name'), user_id: r.get('id'), permission_level: 1}));
    });
  },
  
  userRemoved: function(store, record){
    var store = this.permission_grid.getStore();
    var i = store.find('user_id', new RegExp('^' + record.get('id') + '$'));
    var rec = store.getAt(i);
    store.remove(rec);
    this.removed_records.push(rec);
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

Talho.ScriptManager.reg('Talho.VMS.CreateAndEditScenario', Talho.VMS.CreateAndEditScenario, function(config){return new Talho.VMS.CreateAndEditScenario(config);});
