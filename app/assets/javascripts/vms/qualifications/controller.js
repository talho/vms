/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.QualificationController = Ext.extend(function(){}, {
  constructor: function(config){
    Ext.apply(this, config);
  },
  
  create: function(win, tag, role_id){
    win.showMask('Saving...');
    var params = {
      qualification: tag
    }
    if(role_id){
      params['role_id'] = role_id
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/qualifications',
      method: 'POST',
      params: params,
      scope: this,
      callback: function(opt, success, response){
        var resp = Ext.decode(response.responseText);
        if(success && resp.success === true){
          
        }
        else{
          Ext.Msg.alert('Error', 'There was a problem saving this qualification');
        }
        win.close();
        this.grid.getStore().load();
      }
    });
  },
  
  edit: function(win, tag, role_id){
    win.showMask('Saving...');
    var params = {
      qualification: tag,
      original_qualification: win.creatingRecord.get('name')
    }
    if(!Ext.isEmpty(win.creatingRecord.get('role_id'))){
      params['original_role_id'] = win.creatingRecord.get('role_id');
    }
    if(role_id){
      params['role_id'] = role_id;
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/qualifications',
      method: 'PUT',
      params: params,
      scope: this,
      callback: function(opt, success, response){
        var resp = Ext.decode(response.responseText);
        if(success && resp.success === true){
          
        }
        else{
          Ext.Msg.alert('Error', 'There was a problem saving this qualification');
        }
        win.close();
        this.grid.getStore().load();
      }
    });
  },
  
  remove: function(qual_record){
    var params = {
      qualification: qual_record.get('name')
    };
    if(!Ext.isEmpty(qual_record.get('role_id'))){
      params['role_id'] = qual_record.get('role_id');
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/qualifications.json',
      method: 'DELETE',
      params: params,
      scope: this,
      callback: function(opt, success, response){
        var resp = Ext.decode(response.responseText);
        if(success && resp.success === true){
          
        }
        else{
          Ext.Msg.alert('Error', 'There was a problem removing this qualification');
        }
        this.grid.getStore().load();
      }
    });
  }
});
