//= require ext_extensions/xActionColumn
//= require ../item_detail_windows
//= require ./create_and_edit

/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.RolesController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    this.addEvents('aftersave');
    Ext.apply(this, config);
    Talho.VMS.ux.RolesController.superclass.constructor.apply(this, arguments);
  },
  
  save: function(win, updated_records, deleted_records){    
    var roles = [];
    Ext.each(updated_records, function(r){
      roles.push(this.buildRoleObject(r));
    }, this)
    
    Ext.each(deleted_records, function(r){
      roles.push(this.buildRoleObject(r, 'deleted'));
    }, this)
    
    if(Ext.isEmpty(roles)){
      this.fireEvent('aftersave', this, win);
      return;
    }
    
    // Build an ajax call to handle the save
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/roles.json',
      method: 'PUT',
      params: {
        roles: Ext.encode(roles)
      },
      callback: function(opt, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success === true){
          
        }
        else{
          Ext.Msg.alert("There was a problem saving the roles");
        }
        this.fireEvent('aftersave', this, win);
      },
      scope: this
    });
  },
  
  buildRoleObject: function(r, status_override){
    var val = {
        status: status_override ? status_override : r.phantom ? 'new' : 'updated',
        role_id: r.get('role_id'),
        count: r.get('count')
    }
    
    if(!r.phantom) val['id'] = r.id;
    
    return val;
  }
});
