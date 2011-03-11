/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.SiteController = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.VMS.ux.SiteController.superclass.constructor.apply(this, arguments);
  },
  
  create: function(win, record){
    win.showMask();
    var addr = win.getComponent('address_field').getValue();
    var name = win.getComponent('name_field').getRawValue();
    
    var rec = win.mode == 'activate' ? record : new this.store.recordType({status: 'active', type: 'site'});
    if(win.mode != 'activate' || this.store.indexOf(rec) === -1)
      this.store.add(rec);
    else
      rec.set('status', 'active');
    
    rec.set('address', addr);
    rec.set('name', name);
    
    var add_marker_local = function(loc){
      rec.set('lat', loc.lat());
      rec.set('lng', loc.lng());
      
      Ext.Ajax.request({
        method: win.mode == 'activate' ? 'PUT' : 'POST',
        url: '/vms/scenarios/' + this.scenarioId + '/sites' + (win.mode == 'activate' ? '/' + rec.get('id') : ''),
        scope: this,
        params: {
          'site[name]': rec.get('name'),
          'site[address]': rec.get('address'),
          'site[lat]': rec.get('lat'),
          'site[lng]': rec.get('lng'),
          'status': rec.get('status') === 'active' ? 2 : 1
        },
        success: function(response){
          var resp = Ext.decode(response.responseText);
          var id = resp.site.site_id;
          rec.set('id', id);
          rec.id = id;
          this.map.addMarker(loc, rec.get('name'), {record: rec});
          this.store.commitChanges();
          win.hideMask();
          win.close();                
        },
        failure: function(){
          Ext.Msg.alert('There was an error saving the site');
          win.hideMask();
          win.close();
        }
      });
    }.createDelegate(this);
    
    if(addr != win.original_address){
      this.map.geocoder.geocode({address: addr}, function(results, status){
        add_marker_local(results[0].geometry.location);
      });
    }
    else {
      add_marker_local(win.latLng);
    }
  },
  
  edit: function(win, record, marker){
    win.showMask();
    var addr = win.getComponent('address_field').getValue();
    var name = win.getComponent('name_field').getValue();
    
    var rec = record;
    rec.set('address', addr);
    rec.set('name', name);
    
    var update_record = function(loc){
      rec.set('lat', loc.lat());
      rec.set('lng', loc.lng());
      
      Ext.Ajax.request({
        method: 'PUT',
        url: '/vms/scenarios/' + this.scenarioId + '/sites/' + rec.get('id'),
        scope: this,
        params: {
          'site[name]': rec.get('name'),
          'site[address]': rec.get('address'),
          'site[lat]': rec.get('lat'),
          'site[lng]': rec.get('lng')
        },
        success: function(response){
          if(rec.get('status') == 'active' && addr != win.original_address && marker ){
            marker.setPosition(loc);
          }
          this.store.commitChanges();
          win.close();                
        },
        failure: function(){
          Ext.Msg.alert('There was an error saving the site');
          win.close();
        }
      });
    }.createDelegate(this);
    
    if(addr != win.original_address){
      this.map.geocoder.geocode({address: addr}, function(results, status){
        update_record(results[0].geometry.location);
      });
    }
    else {
      update_record(new google.maps.LatLng(rec.get('lat'), rec.get('lng')) );
    }
  },
  
  destroy: function(record, marker){
    Ext.Ajax.request({
      method: 'DELETE',
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + record.id,
      scope: this,
      success: function(){
        this.store.remove(record);
        if(marker){
          this.map.removeMarker(marker);
        }
      },
      failure: function(){
        Ext.Msg.alert('There was an error deleting the site');
      }
    });
  },
  
  deactivate: function(record, marker, grid){
    grid.loadMask.show();
    // send ajax deactivation request
    Ext.Ajax.request({
      method: 'PUT',
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + record.id,
      params: { 'status': 1 },
      scope: this,
      success: function(){
        grid.loadMask.hide();
        record.set('status', 1);
        if(marker){
          this.map.removeMarker(marker);
        }
      },
      failure: function(){
        grid.loadMask.hide();
        Ext.Msg.alert('There was an error deactivating the site');
      }
    });
  }
});
