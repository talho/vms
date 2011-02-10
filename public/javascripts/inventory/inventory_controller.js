Ext.ns('Talho.VMS.ux');

(function(){
  
  var inv_controller = Ext.extend(Ext.util.Observable, {
    constructor: function(config){
      inv_controller.superclass.constructor.apply(this, arguments);
    },
    
    record: Ext.data.Record.create(['name', 'id', 
      {name: 'type', mapping: 'pod', convert: function(val){ if(val === true) return 'pod'; else return 'inventory'; }, defaultValue: 'inventory' }, 
      {name: 'status', defaultValue: 'active' },
      {name: 'template', defaultValue: false, type: 'boolean'},
      {name: 'source', convert: function(val){
        if(Ext.isString(val)) return val;
        else if(Ext.isObject(val)) return val.name;
        else return val;
      }},
      'items',
      {name: 'site_id', mapping: 'site', type: 'int', convert: function(val){
        if(val && val.id) return val.id;
        else return null;
      }}
    ]),
    
    inventory_list_store: Ext.extend(Ext.data.JsonStore, {
      constructor: function(config){
        Ext.apply(config, {
          url: Talho.VMS.ux.InventoryController.build_url(config.scenarioId),
          fields: Talho.VMS.ux.InventoryController.record,
          idProperty: 'id'
        });
        Talho.VMS.ux.InventoryController.inventory_list_store.superclass.constructor.apply(this, arguments); 
      },
      restful: true,
      autoLoad: false
    }),
    
    inventory_template_store: Ext.extend(Ext.data.JsonStore, {
      constructor: function(config){
        Ext.apply(config, {
          url: 'vms/scenarios/' + config.scenarioId + '/inventories/templates',
          fields: Talho.VMS.ux.InventoryController.record,
          idProperty: 'id'
        });
        Talho.VMS.ux.InventoryController.inventory_template_store.superclass.constructor.apply(this, arguments);
      },
      restful: true,
      autoLoad: false
    }),
    
    create: function(win, values, record, scenarioId, site, store){
      record = record.copy();
      record.id = Ext.data.Record.id(record);
  
      record.set('name', values.name);
      record.set('type', values.type);
      record.set('template', values.template);
      record.set('source', values.source);
      record.set('status', 'active');
      
      this.save(record, values.items, 'create', scenarioId, site.id, function(opts, success, response){
        var resp_obj = Ext.decode(response.responseText);
        if(success && (resp_obj.success !== undefined && resp_obj.success !== false) ){
          record.set('id', resp_obj.inventory.id);
          record.id = resp_obj.inventory.id;
          store.add(record); 
          store.commitChanges();
          
          if(!site.get('inventory'))
            site.set('inventory', []); // initialize an empty array for the type that we just dragged onto this site
          var arr = site.get('inventory');
          
          if(arr.indexOf(record) == -1){ // only add if the item does not exist in that site already
            arr.push(record);
          }
          record.site = site;
          win.close();
        }
        else{
          Ext.Msg.alert("Error", "There was an error saving the POD/inventory. " + resp_obj.error);
        }
      }, this);
    },
    
    edit: function(win, values, record, scenarioId, store){
      record.set('name', values.name);
      record.set('type', values.type);
      record.set('template', values.template);
      record.set('source', values.source);
      record.set('status', 'active');
      
      this.save(record, values.items, 'edit', scenarioId, null, function(opts, success, response){
        var resp_obj = Ext.decode(response.responseText);
        if(success && (resp_obj.success !== undefined && resp_obj.success !== false) ){
          store.commitChanges();
          win.close();
        }
        else{
          Ext.Msg.alert("Error", "There was an error saving the POD/inventory. " + resp_obj.error);
        }
      }, this);
    },
    
    destroy: function(record, scenarioId){
      
    },
    
    build_url: function(scenario_id, inventory_id, site_id){
      return '/vms/scenarios/' + scenario_id + '/inventories' + (inventory_id ? '/' + inventory_id : '') + '.json' + (site_id ? '?site_id=' + site_id : '');
    },
    
    build_params: function(record, items){
      var params = {
        'inventory[name]': record.get('name'),
        'inventory[pod]': record.get('type') == 'pod',
        'inventory[template]': record.get('template'),
        'source': record.get('source')
      }
      
      if(items && items.length > 0){
        Ext.each(items, function(item, i){
          params['items[' + i + '][name]'] = item.get('name');
          params['items[' + i + '][quantity]'] = item.get('quantity');
          params['items[' + i + '][category]'] = item.get('category');
          params['items[' + i + '][consumable]'] = item.get('consumable'); 
        });
      }
      else if(items){
        params['items'] = '';
      }
      
      return params;
    },
    
    save: function(record, items, mode, scenarioId, siteId, callback, scope){
      Ext.Ajax.request({
        url: this.build_url(scenarioId, mode !== 'create' ? record.get('id') : null, siteId ? siteId : null),
        method: mode == 'edit' ? 'PUT' : (mode == 'delete' ? 'DELETE' : 'POST'),
        params: mode == 'delete' ? {} : this.build_params(record, items),
        callback: callback,
        scope: scope
      });
    }
  });
  
  Talho.VMS.ux.InventoryController = new inv_controller();
})();
