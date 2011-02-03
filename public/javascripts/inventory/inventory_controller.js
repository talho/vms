Ext.ns('Talho.VMS.ux.Inventory');

(function(){
  
  var inv_controller = Ext.extend(Ext.util.Observable, {
    constructor: function(config){
      inv_controller.superclass.constructor.apply(this, arguments);
    },
    
    record: Ext.data.Record.create(['name', 'id', 
      {name: 'type', mapping: 'pod', convert: function(val){ if(val === true) return 'pod'; else return 'inventory'; }, defaultValue: 'inventory' }, {name: 'status', defaultValue: 'active' }
    ]),
    
    inventory_list_store: Ext.extend(Ext.data.JsonStore, {
      constructor: function(config){
        Ext.apply(config, {
          url: Talho.VMS.ux.Inventory.InventoryController.build_url(config.scenarioId),
          fields: Talho.VMS.ux.Inventory.InventoryController.record,
          idProperty: 'id'
        });
        Talho.VMS.ux.Inventory.InventoryController.inventory_list_store.superclass.constructor.apply(this, arguments); 
      },
      restful: true,
      autoLoad: false
    }),
    
    create: function(win, name, type, record, site, store){
      var rec = record.copy();
      rec.id = Ext.data.Record.id(rec);
      store.add(rec);
        
      record = rec;
      record.set('name', name);
      record.set('type', type);
      record.set('status', 'active');
      
      if(!site.get(record.get('type')))
        site.set(record.get('type'), []); // initialize an empty array for the type that we just dragged onto this site
      var arr = site.get(record.get('type'));
      
      if(arr.indexOf(record) == -1){ // only add if the item does not exist in that site already
        arr.push(record);
      }
      record.site = site;
      win.close();
    },
    
    build_url: function(scenario_id, inventory_id, site_id){
      return '/vms/scenarios/' + scenario_id + '/inventories' + (inventory_id ? '/' + inventory_id : '') + '.json' + (site_id ? '?site_id=' + site_id : '');
    },
    
    build_params: function(record){
      var params = {
        'inventory[name]': record.get('name'),
        'inventory[pod]': record.get('type') == 'pod',
        'inventory[template]': record.get('template')
      }
      
      return params;
    },
    
    save: function(record, mode, scenarioId, site, callback){
      Ext.Ajax.request({
        url: this.build_url(scenarioId, mode == 'edit' ? record.id : null, site? site.id : null),
        method: mode == 'edit' ? 'PUT' : (mode == 'delete' ? 'DELETE' : 'POST'),
        params: mode == 'delete' ? {} : this.build_params(),
        callback: callback
      });
    }
  });
  
  Talho.VMS.ux.Inventory.InventoryController = new inv_controller();
})();
