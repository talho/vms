/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.CreateAndEditStaff = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  title: "Modify Staff",
  initComponent: function(){
    this.deleted_records = [];
    var start_editing = Ext.isDefined(this.creatingRecord);
  
    // Now create the grid and the stuff to add new rows
    this.layout = 'fit';
    this.items = [
      new Talho.ux.UserSelectionGrid({
        height: 350,
        itemId: 'users',
        hideLabel: true,
        cls: 'user_selection_grid',
        listeners:{
          scope: this,
          'beforeselect': this.beforeUserSelected
        }
      })
    ];
    
    this.original_user_store = new Ext.data.JsonStore({
      fields: ['user', {name: 'type', defaultValue: 'manual_user'}, {name: 'status', defaultValue: 'active'}, 'id', 'site_id', 'site', 'user_id']
    });
    
    Talho.VMS.ux.CreateAndEditStaff.superclass.initComponent.apply(this, arguments);
    
    this.user_selection_grid = this.getComponent('users');
    
    this.on('afterrender', this.loadData, this, {delay: 1});
  },
  
  loadData: function(){
    this.showMask('Loading...');
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/staff.json',
      method: 'GET',
      callback: function(opts, success, resp){
        if(success){
          this.hideMask();
          var result = Ext.decode(resp.responseText);
          this.original_user_store.loadData(result);
          var users = [];
          Ext.each(result, function(r){
            users.push(r.user_detail);
          });
          this.user_selection_grid.getStore().loadData(users);
        }
        else{
          Ext.Msg.alert('There was a problem loading the staff for this site');
          this.close();
        }
      },
      scope: this
    });
  },
    
  onSaveClicked: function(){
    var added_records = [],
        removed_records = [],
        cstr = this.original_user_store.recordType,
        user_selection_store = this.user_selection_grid.getStore();
        
    Ext.each(user_selection_store.getModifiedRecords(), function(r){
      added_records.push(new cstr({ status: 'assigned', user_id: r.get('id') }));
    }, this);
    
    this.original_user_store.each(function(r){
      if(!user_selection_store.getById(r.get('user_id')))
        removed_records.push(r);
    }, this);
    
    this.fireEvent('save', this, added_records, removed_records);
  },
  
  beforeUserSelected: function(record){
    var id = record.get('id');
    var index = this.scenario_staff_store.find('user_id', new RegExp("^" + id + "$"));
    if(index !== -1 && this.scenario_staff_store.getAt(index).get('site_id') != this.siteId){
      Ext.Msg.confirm("Move User", record.get('name') + " is already assigned to a site. Would you like to reassign them?", function(btn){
        if(btn === 'yes'){
          this.user_selection_grid.getStore().add(new this.user_selection_grid.record({name: record.get('name'), email: record.get('email'), id: record.get('id'), title: record.get('title'), tip: record.get('extra'), type: 'user'}));
        }
      }, this);
      return false;
    }
    else
      return true;
  }
});