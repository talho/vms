/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.StaffController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.VMS.ux.StaffController.superclass.constructor.apply(this, arguments);
  },
  
  save: function(win, added_records, deleted_records){
    // Mask the window
    win.showMask();
    
    var add = [], del = [];
    Ext.each(added_records, function(r){
      add.push(this.buildStaffObject(r));
    }, this)
    
    Ext.each(deleted_records, function(r){
      del.push(this.buildStaffObject(r));
    }, this)
    
    if(Ext.isEmpty(add) && Ext.isEmpty(del)){
      win.close();
      this.store.load();
      return;
    }
    
    // Build an ajax call to handle the save
    Ext.Ajax.request({
      url: this.getUrl(),
      method: 'PUT',
      params: {
        added_staff: Ext.encode(add),
        removed_staff: Ext.encode(del)
      },
      callback: function(opt, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success === true){
          
        }
        else{
          Ext.Msg.alert("There was a problem saving the staff");
        }
        win.close();
        this.store.load();
      },
      scope: this
    });
  },
  
  remove: function(record, grid){
    var rm = [this.buildStaffObject(record)];
    if(grid)
      grid.loadMask.show();
      
    Ext.Ajax.request({
      url: this.getUrl(),
      method: 'PUT',
      params: {
        removed_staff: Ext.encode(rm)
      },
      callback: function(opt, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success === true){
          
        }
        else{
          Ext.Msg.alert("There was a problem saving the staff");
        }
        this.store.load();
      },
      scope: this
    })
  },
  
  move: function(record, grid){
    var ad = [this.buildStaffObject(record)];
    if(grid)
      grid.loadMask.show();
     
    Ext.Ajax.request({
      url: this.getUrl(),
      method: 'PUT',
      params: {
        added_staff: Ext.encode(ad)
      },
      callback: function(opt, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success === true){
          
        }
        else{
          Ext.Msg.alert("There was a problem saving the staff");
        }
        this.store.load();
      },
      scope: this
    });
  },
  
  buildStaffObject: function(r){
    var val = {
        status: r.get('status'),
        user_id: r.get('user_id')
    }
    
    if(!r.phantom) val['id'] = r.id;
    
    return val;
  },
  
  getUrl: function(){
    return '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/staff.json';
  }
});
