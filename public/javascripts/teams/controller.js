/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux')

Talho.VMS.ux.TeamController = Ext.extend(function(){}, {
  constructor: function(config){
    Ext.apply(this, config);
  },
  
  save: function(win, name, template, user_ids, parent_group_id){
    win.showMask('Saving...');
    
    var params = {
        'save_template' : template,
        'team[audience][name]' : name,
        'team[audience][user_ids][]' : user_ids
    };
    if(parent_group_id){
      params['audience_parent_id'] = parent_group_id;
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/teams',
      method: 'POST',
      params: params,
      callback: function(options, success, response){
        win.hideMask();
        var result = Ext.decode(response.responseText);
        if(success && result.success != false){
        }
        else{
          Ext.Msg.alert('Save Error', 'There was a problem saving the team.');
        }
        this.grid.getStore().load();
        win.close();
      },
      scope: this
    });
  },
  
  edit: function(win, id, name, user_ids){
    win.showMask('Saving...');
    
    var params = {
      'team[audience][name]' : name
    };
    
    if(!Ext.isEmpty(user_ids)){
      params['team[audience][user_ids][]'] = user_ids;
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/teams/' + id,
      method: 'PUT',
      params: params,
      callback: function(options, success, response){
        win.hideMask();
        var result = Ext.decode(response.responseText);
        if(success && result.success != false){
        }
        else{
          Ext.Msg.alert('Save Error', 'There was a problem saving the team.');
        }
        this.grid.getStore().load();
        win.close();
      },
      scope: this
    });
  },
  
  remove: function(id){
    this.grid.loadMask.show();
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/teams/' + id,
      method: 'DELETE',
      callback: function(options, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success != false){
        }
        else{
          Ext.Msg.alert('Save Error', 'There was a problem saving the team.');
        }
        this.grid.getStore().load();
      },
      scope: this
    });
  },
  
  move: function(record, site){
    this.grid.loadMask.show();
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + record.get('site_id') + '/teams/' + record.id + '.json',
      method: 'PUT',
      params: {
        'site_id': site.id
      },
      callback: function(options, success, response){
        var result = Ext.decode(response.responseText);
        if(success && result.success != false){
        }
        else{
          Ext.Msg.alert('Save Error', 'There was a problem saving the team.');
          this.grid.loadMask.hide();
        }
        this.grid.getStore().load();
      },
      scope: this
    });
  }
});
