/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.StaffController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    this.addEvents('aftersave', 'afterremove', 'aftermove');
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
      this.fireEvent('aftersave', this, win);
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
        this.fireEvent('aftersave', this, win);
      },
      scope: this
    });
  },
  
  remove: function(record){
    var rm = [this.buildStaffObject(record)];
      
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
        this.fireEvent('afterremove', this);
      },
      scope: this
    })
  },
  
  move: function(record){
    var ad = [this.buildStaffObject(record)];
     
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
        this.fireEvent('aftermove', this);
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
