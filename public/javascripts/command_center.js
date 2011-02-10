Ext.ns("Talho.VMS");

Talho.VMS.CommandCenter = Ext.extend(Ext.Panel, {
  title: 'VMS Command Center',
  closable: true,
  layout: 'border',
  
  constructor: function(config){
    this.row_template = new Ext.XTemplate(
      '<div class="vms-tool-row">',
        '<div class="vms-row-icon {[this.iconClass(values)]}"></div>',
        '<div class="vms-row-text">{name}</div>',
        '<div style="clear:both;"></div>',
      '</div>',
      {
        compiled: true,
        iconClass: function(values){
          var cls = '';
          switch(values.status){
            case 'active': cls = 'vms-tool-icon-active ';
              break;
            case 'new': cls = 'vms-tool-icon-new ';
              break;
            default: cls = 'vms-tool-icon-inactive ';
              break;
          }
          
          switch(values.type){
            case 'site': cls += 'vms-site';
              break;
            case 'inventory': cls += 'vms-inventory';
              break;
            case 'pod': cls += 'vms-pod';
              break;
            case 'profile': cls += 'vms-profile';
              break;
            case 'role': cls += 'vms-role';
              break;
            case 'team': cls += 'vms-team';
              break;
            case 'auto_user': cls += 'vms-auto-user';
              break;
            case 'manual_user': cls += 'vms-manual-user';
              break;
          }
          
          return cls;
        }
    });
    
    var vms_tool_grid = Ext.extend(Ext.grid.GridPanel, {
      hideHeaders: true, enableDragDrop: true, ddGroup: 'vms',
      loadMask: true,
      columns: [{xtype: 'templatecolumn', id: 'name_column', tpl: this.row_template}],
      autoExpandColumn: 'name_column', buttonAlign: 'right',
      constructor: function(config){
        Ext.applyIf(config, {sm: new Ext.grid.RowSelectionModel({
          singleSelect: true,
          listeners: {
            scope: this,
            'beforerowselect': function(sm, i, ke, record){
              this.ddText = this.getColumnModel().getColumnById('name_column').tpl.apply(record.data);
            } 
          }
        })});
        vms_tool_grid.superclass.constructor.call(this, config);
        this.getStore().on('load', this.add_default_rows, this);
      },
      add_default_rows: function(store){
        var fn = function(rec_data){
          store.insert(0, new (store.recordType)(rec_data));
        }
        if(Ext.isArray(this.seed_data)){
          for(var i = this.seed_data.length - 1; i >= 0; i--){
            fn(this.seed_data[i]);
          }
        }
        else if(Ext.isObject(this.seed_data)){
          fn(this.seed_data);
        }
      }
    });
    
    Ext.reg('vms-toolgrid', vms_tool_grid);
    
    var tool_store = Ext.extend(Ext.data.Store, {
      reader: new Ext.data.JsonReader({fields: ['name', 'type', 'status']}),
      autoLoad: false
    });
    
    var tool_cfg = [{id: 'refresh', handler: function(evt, el, pnl){pnl.getStore().load();}}];
    
    this.items = [{
          region: 'center',
          itemId: 'map',
          xtype: 'gmappanel',
          zoomLevel: 10,
          gmapType: 'map',
          mapConfOpts: ['enableScrollWheelZoom','enableDoubleClickZoom','enableDragging'],
          mapControls: ['GSmallMapControl','GMapTypeControl','NonExistantControl'],
          setCenter: {
              geoCodeAddr: 'Lufkin, Tx, USA'
          },
          listeners: {
            scope: this,
            'afterrender': {
              fn: this.initMapDropZone,
              delay: 1
            },
            'markerclick': this.showSiteMarkerInfo
          }
      },
      { xtype: 'container', itemId: 'westRegion', region: 'west', layout: 'accordion', items:[
        { title: 'Site', itemId: 'siteGrid', xtype: 'vms-toolgrid', tools: tool_cfg, seed_data: {name: 'New Site (drag to create)', status: 'new', type: 'site'},
          store: new tool_store({
            reader: new Ext.data.JsonReader({
              root: 'sites',
              idProperty: 'site_id',
              fields: [{name:'name', mapping:'site.name'}, {name: 'type', defaultValue: 'site'}, {name:'status', convert: function(v){return v == 2 ? 'active': 'inactive';} }, {name: 'address', mapping: 'site.address'}, {name: 'lat', mapping: 'site.lat'}, {name: 'lng', mapping: 'site.lng'}, {name: 'id', mapping: 'site_id'}]
            }),
            url: '/vms/scenarios/' + config.scenarioId + '/sites',
            listeners:{
              scope: this,
              'load': this.initializeSiteMarkers
            }
          }),
          listeners: {
            scope: this,
            'rowcontextmenu': this.showSiteContextMenu
          }
        },
        {title: 'PODS/Inventory', xtype: 'vms-toolgrid', tools: tool_cfg, itemId: 'inventory_grid', seed_data: {name: 'New POD/Inventory (drag to site)', type: 'inventory', status: 'new'},
          store: new Talho.VMS.ux.InventoryController.inventory_list_store({ scenarioId: config.scenarioId,
            listeners: {
              scope: this,
              'load': this.applyToSite
          } }),
          listeners: {
            scope: this,
            'rowcontextmenu': this.showInventoryContextMenu
          }
        }
      ], plugins: ['donotcollapseactive'], width: 200, split: true },
      { xtype: 'container', itemId: 'eastRegion', region: 'east', layout: 'accordion', items:[
        {title: 'Exigency Profile', xtype: 'vms-toolgrid',
          store: new tool_store()
        },
        {title: 'Roles', xtype: 'vms-toolgrid', itemId: 'roles_grid', seed_data: {name: 'Add Role (drag to site)', type: 'role', status: 'new'},
          store: new tool_store()
        },
        {title: 'Teams', xtype: 'vms-toolgrid', itemId: 'teams_grid', seed_data: {name: 'New Team (drag to site)', type: 'team', status: 'new'},
          store: new tool_store()
        },
        {title: 'Staff', xtype: 'vms-toolgrid', itemId: 'staff_grid', seed_data: {name: 'Add User (drag to site)', type: 'manual_user', status: 'new'},
          store: new tool_store()
        }
      ], plugins: ['donotcollapseactive'], width: 200, split: true }
    ];
    
    Talho.VMS.CommandCenter.superclass.constructor.apply(this, arguments);
  },

  initComponent: function(){
    Talho.VMS.CommandCenter.superclass.initComponent.apply(this, arguments);
    
    this.westRegion = this.getComponent('westRegion');
    this.siteGrid = this.westRegion.getComponent('siteGrid');
    this.inventoryGrid = this.westRegion.getComponent('inventory_grid');
    this.eastRegion = this.getComponent('eastRegion');
    this.rolesGrid = this.eastRegion.getComponent('roles_grid');
    this.teamsGrid = this.eastRegion.getComponent('teams_grid');
    this.staffGrid = this.eastRegion.getComponent('staff_grid');
    this.map = this.getComponent('map');
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId,
      method: 'GET',
      success: this.loadScenario_success,
      scope: this
    });
    
    this.on('afterrender', function(){
      if(!this.initial_load_complete){
        this.loadMask = new Ext.LoadMask(this.getLayoutTarget());
        this.loadMask.show();
      }
    }, this, {delay: 1});
  },
  
  loadScenario_success: function(response, options){
    this.initial_load_complete = true;
    if(this.loadMask) this.loadMask.hide();
    
    var result = Ext.decode(response.responseText);
    
    this.siteGrid.getStore().load();
    this.inventoryGrid.getStore().load();
    this.rolesGrid.getStore().loadData([]);
    this.teamsGrid.getStore().loadData([]);
    this.staffGrid.getStore().loadData([]);
  },
  
  initMapDropZone: function(){
    this.map.dropZone = new Ext.dd.DropZone(this.map.getEl(), {
      parent: this,
      map: this.map,
      ddGroup: 'vms',
      
      getTargetFromEvent: function(e){
        var target = e.getTarget('div');
        if(this.map.getCurrentHover()){
          return target;
        }
        else{
          return Ext.dd.Registry.getTargetFromEvent(e); 
        }
      },
      
      onNodeOver: function(target, dd, e, data){
        if(data.selections[0].get('type') == 'site')
          return this.dropNotAllowed;
        else
          return this.dropAllowed;
      },
            
      onContainerOver: function(dd, e, data){ 
        if(data.selections[0].get('type') == 'site')
          return this.dropAllowed;
        else
          return this.dropNotAllowed;
      },
      
      onNodeDrop: function(target, dd, e, data){
        var rec = data.selections[0];
        if(rec.get('type') == 'site'){
          return false;
        }
        
        var marker = this.map.getCurrentHover();
        if(marker && marker.data && marker.data.record){
          this.parent.addItemToSite(marker.data.record, rec);
          return true;
        }
        else
          return false;
      },
      
      onContainerDrop: function(dd, e, data){
        if(data.selections[0].get('type') == 'site'){
          this.parent.addSiteToMap(this.map.getCurrentLatLng(), data.selections[0]);
          return true;
        }
        else{
          return false;
        }
      }
    });
  },
  
  /**
   * Launches the new/edit site window to allow a user to name their site, adjust their address. On save, add record to the grid as active or set the item status to active
   * @param {LatLng} latLng Google's latitude/longitude object for where the record was dropped.
   * @param {Record} record Ext record that represents the transported object
   */
  addSiteToMap: function(latLng, record){
    var mode = 'activate';
    
    if(record.get('status') == 'new')
      mode = 'new';
    else if(record.get('status') == 'active')
      mode = 'copy';
    
    var original_address = '';
    if(mode == 'activate' && !Ext.isEmpty(record.get('address')) ){
      original_address = record.get('address');
      this.map.geocoder.geocode({address: original_address}, function(results, status){
        latLng = results[0].geometry.location;
      }.createDelegate(this));
    }
    else {
      this.map.geocoder.geocode({latLng: latLng}, function(results, status){
        original_address = results[0].formatted_address;
        win.getComponent('address_field').setValue(original_address);
      }.createDelegate(this));
    }

    var name_field_config = {xtype: 'textfield', itemId: 'name_field', fieldLabel: 'Name', value: mode != 'new' ? (mode == 'copy' ? 'Copy of ' : '') + record.get('name') : '' };
    
    if(mode === 'new'){
      var json_store = new Ext.data.JsonStore({
          url: '/vms/scenarios/' + this.scenarioId + '/sites/existing',
          idProperty: 'id',
          root: 'sites',
          fields: ['name', 'lat', 'lng', 'id', 'address']
      });
      Ext.apply(name_field_config, {xtype: 'combo', queryParam: 'name',
          mode: 'remote', triggerAction: 'query', typeAhead: true,
          store: json_store, displayField: 'name', valueField: 'name',
          tpl:'<tpl for="."><div ext:qtip=\'{address}\' class="x-combo-list-item">{name}</div></tpl>',
          minChars: 0,
          listeners: {
            scope: this,
            'select': function(combo, r, index){
              mode = 'activate';
              record = new (this.siteGrid.getStore().recordType)({status: 'active', type: 'site'});
              record.id = r.get('id');
              record.set('id', r.get('id'));
              record.set('name', r.get('name'));
              record.set('address', r.get('address'));
              record.set('lat', r.get('lat'));
              record.set('lng', r.get('lng'));
              win.getComponent('address_field').setValue(r.get('address'));
            }
          }});
    }

    var win = new Talho.VMS.ux.ItemDetailWindow({
      items: [
        name_field_config,
        {xtype: 'textfield', itemId: 'address_field', fieldLabel: 'Address', value: original_address}
      ],
      listeners:{
        scope: this,
        'save': function(win){
          var store = this.siteGrid.getStore();
          var addr = win.getComponent('address_field').getValue();
          var name = win.getComponent('name_field').getValue();
          
          var rec = mode == 'activate' ? record : new store.recordType({status: 'active', type: 'site'});
          if(mode != 'activate' || store.indexOf(rec) === -1)
            store.add(rec);
          else
            rec.set('status', 'active');
          
          rec.set('address', addr);
          rec.set('name', name);
          
          var add_marker_local = function(loc){
            rec.set('lat', loc.lat());
            rec.set('lng', loc.lng());
            
            Ext.Ajax.request({
              method: mode == 'activate' ? 'PUT' : 'POST',
              url: '/vms/scenarios/' + this.scenarioId + '/sites' + (mode == 'activate' ? '/' + rec.get('id') : ''),
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
                this.siteGrid.getStore().commitChanges();
                win.close();                
              },
              failure: function(){
                Ext.Msg.alert('There was an error saving the site');
                win.close();
              }
            });
          }.createDelegate(this);
          
          if(addr != original_address){
            this.map.geocoder.geocode({address: addr}, function(results, status){
              add_marker_local(results[0].geometry.location);
            });
          }
          else {
            add_marker_local(latLng);
          }
        }
      }      
    });
    
    win.show();
  },
  
  addItemToSite: function(site, record){
    var init_record = function(rec){
      rec.set('status', 'active');
      
      if(!site.get(rec.get('type')))
        site.set(rec.get('type'), []); // initialize an empty array for the type that we just dragged onto this site
      var arr = site.get(rec.get('type'));
      
      if(arr.indexOf(rec) == -1){ // only add if the item does not exist in that site already
        arr.push(rec);
      }
    };
    
    var prep_record = function(rec){
      if(record.get('status') != 'inactive'){
        var rec = record.copy();
        rec.id = Ext.data.Record.id(rec);
        this.addItemToTypeStore(rec);
      }
      return rec;
    }.createDelegate(this);
    
    if(record.get('type') == 'inventory' || record.get('type') == 'pod'){
      var win = new Talho.VMS.ux.InventoryWindow({
        scenarioId: this.scenarioId,
        record: record,
        listeners: {
          'save': Talho.VMS.ux.InventoryController.create.createDelegate(Talho.VMS.ux.InventoryController, [record, this.scenarioId, site, this.inventoryGrid.getStore()], true) 
        }
      });
      win.show();
    }
    else if(record.get('type') === 'role'){
      if(record.get('status') == 'new'){
        var win = new Talho.VMS.ux.RoleWindow({
          listeners: {
            scope: this,
            'save': function(win, role){
              record = prep_record(record);
              record.set('name', role);
              init_record(record);
              win.close();
            }
          }
        });
        win.show();
      }
      else{
        init_record(record);
      }
    }
    else if(record.get('type') === 'team'){
      var win = new Talho.VMS.ux.TeamWindow({
        record: record,
        listeners: {
          scope: this,
          'save': function(win, name, users){
            if(record.get('status') === 'new')
              record = prep_record(record);
            if(record.get('status') === 'active' && record.site)
              record.site.get('team').remove(record);
            record.set('name', name);
            record.site = site;
            init_record(record);
            
            var manual_users = [];
            Ext.each(users, function(user){
              var u = this.staffGrid.getStore().find('name', user.get('name'));
              if(u !== -1){
                u = this.staffGrid.getStore().getAt(u);
                if(u.get('status') === 'active' && record.site)
                  u.site.get('auto_user').remove(u);// remove the user from his current site
              }
              else{
                u = new (this.staffGrid.getStore().recordType)({name: user.get('name'), status: 'new', type: 'auto_user'});
                this.addItemToTypeStore(u);                
              }
              manual_users.push(u);
              init_record(u);
              u.site = site;
            }, this);
            
            record.users = manual_users;
            win.close();
          }
        }
      });
      win.show();
    }
    else if(record.get('type') === 'manual_user'){
      if(record.get('status') === 'new'){
        var win = new Talho.VMS.ux.UserWindow({
          listeners:{
            scope: this,
            'save': function(win, user){
              record = prep_record(record);
              record.set('name', user);
              init_record(record);
              record.site = site;
              win.close();
            }
          }
        });
        win.show();
      }
      else{
        if(record.get('status') === 'active')
          record.site.get('manual_user').remove(record);// remove the user from his current site
        init_record(record);
        record.site = site;
      }
    }
    else if(record.get('type') === 'auto_user'){
        if(record.get('status') === 'active' && record.site)
          record.site.get('auto_user').remove(record);// remove the user from his current site
        init_record(record);
        record.site = site;
    }
    else{
      record = prep_record(record);
      if(record.status != 'inactive') 
        record.set('name', record.get('status') == 'new' ? ('New ' + Ext.util.Format.capitalize(record.get('type')) ) : ('Copy of ' + record.get('name') ) );        
      init_record(record);
      record.site = site;
    }    
  },
  
  addItemToTypeStore: function(record){
    switch(record.get('type')){
      case 'inventory':
      case 'pod':
        this.inventoryGrid.getStore().add(record);
        break;
      case 'team':
        this.teamsGrid.getStore().add(record);
        break;
      case 'role':
        this.rolesGrid.getStore().add(record);
        break;
      case 'manual_user':
      case 'auto_user':
        this.staffGrid.getStore().add(record);
        break;
    }
  },
  
  showSiteMarkerInfo: function(marker){
    var template = new Ext.XTemplate(
      '<div>{name}</div>',
      '<tpl if="this.has(values, &quot;pod&quot;)"><div>PODS: <tpl for="pod"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;inventory&quot;)"><div>Inventories: <tpl for="inventory"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;profile&quot;)"><div>Profiles: <tpl for="profile"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;role&quot;)"><div>Roles: <tpl for="role"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;team&quot;)"><div>Teams: <tpl for="team"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;manual_user&quot;)"><div>Staff: <tpl for="manual_user"><span>{values.data.name}</tpl></div></tpl>',
      '<tpl if="this.has(values, &quot;auto_user&quot;)"><div>Staff: <tpl for="auto_user"><span>{values.data.name}</tpl></div></tpl>',
      {
        has: function(values, key){ return Ext.isDefined(values[key])},
        test: function(){
          return true;
        }
      }
    );
    this.map.showInfoWindow(marker, Ext.DomHelper.createDom({tag: 'div', html: template.apply(marker.data.record.data)}));
  },
  
  initializeSiteMarkers: function(store, records){
    Ext.each(records, function(record){
      if(record.get('status') === 'active'){
        var marker = this.findMarker(record);
        if(marker){
          marker.data.record = record;
        }
        else{
          this.map.addMarker(new google.maps.LatLng(record.get('lat'), record.get('lng')), record.get('name'), {record: record});
        }
      }
    }, this)
    
    this.applyToSite(this.inventoryGrid.getStore(), this.inventoryGrid.getStore().getRange(), {});
  },
  
  showSiteContextMenu: function(grid, row_index, evt){
    evt.preventDefault();

    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    var menuConfig = [
      {text: 'Edit', scope: this, handler: function(){
        var original_address = record.get('address');
        
        var win = new Talho.VMS.ux.ItemDetailWindow({
          items: [
            {xtype: 'textfield', itemId: 'name_field', fieldLabel: 'Name', value: record.get('name') },
            {xtype: 'textfield', itemId: 'address_field', fieldLabel: 'Address', value: original_address}
          ],
          listeners:{
            scope: this,
            'save': function(win){
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
                    var marker;
                    if(rec.get('status') == 'active' && addr != original_address && (marker = this.findMarker(rec)) ){
                      marker.setPosition(loc);
                    }
                    this.siteGrid.getStore().commitChanges();
                    win.close();                
                  },
                  failure: function(){
                    Ext.Msg.alert('There was an error saving the site');
                    win.close();
                  }
                });
              }.createDelegate(this);
              
              if(addr != original_address){
                this.map.geocoder.geocode({address: addr}, function(results, status){
                  update_record(results[0].geometry.location);
                });
              }
              else {
                update_record(new google.maps.LatLng(rec.get('lat'), rec.get('lng')) );
              }
            }
          }      
        });
        
        win.show();
      }},
      {text: 'Remove', scope: this, handler: function(){
          Ext.Ajax.request({
          method: 'DELETE',
          url: '/vms/scenarios/' + this.scenarioId + '/sites/' + record.id,
          scope: this,
          success: function(){
            grid.getStore().remove(record);
            var marker = null;
            Ext.each(this.map.markers, function(m){ if(m.data.record.id === record.id){
              marker = m;
              return false;
            }});
            if(marker){
              this.map.removeMarker(marker);
            }
          },
          failure: function(){
            Ext.Msg.alert('There was an error deleting the site');
          }
        });
      }}
    ];
    
    if(record.get('status') === 'active'){
      menuConfig.push({text: 'Deactivate', scope: this, handler: function(){
        // send ajax deactivation request
        Ext.Ajax.request({
          method: 'PUT',
          url: '/vms/scenarios/' + this.scenarioId + '/sites/' + record.id,
          params: { 'status': 1 },
          scope: this,
          success: function(){
            record.set('status', 1);
            var marker = this.findMarker(record);
            if(marker){
              this.map.removeMarker(marker);
            }
          },
          failure: function(){
            Ext.Msg.alert('There was an error deactivating the site');
          }
        });
      }});
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  showInventoryContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    var menuConfig = [
      {text: 'Edit', scope: this, handler: function(){
        var win = new Talho.VMS.ux.InventoryWindow({
          scenarioId: this.scenarioId,
          record: record,
          mode: 'edit',
          listeners: {
            'save': Talho.VMS.ux.InventoryController.edit.createDelegate(Talho.VMS.ux.InventoryController, [record, this.scenarioId, grid.getStore()], true) 
          }
        });
        
        win.show();
      }},
      {text: 'Delete', scope: this, handler: function(){
        Talho.VMS.ux.InventoryController.destroy(record, this.scenarioId);
        grid.getStore().load();
      }}
    ];
    // later add in the ability to have inactive inventories already assigned to sites
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  findMarker: function(record){
    var marker = null;
    Ext.each(this.map.markers, function(m){ if(m.data.record.id === record.id){
      marker = m;
      return false;
    }});
    return marker;
  },
  
  applyToSite: function(store, records, opts){
    Ext.each(records, function(record){      
      var site = this.siteGrid.getStore().getById(record.get('site_id'));
      if(site){
        var type = record.get('type');
        type = type === 'pod' ? 'inventory' : type; // show inventory and pod as the same thing
        
        if(!site.get(type))
          site.set(type, []); // initialize an empty array for the type that we just dragged onto this site
        var arr = site.get(type);
        
        if(arr.indexOf(record) == -1){ // only add if the item does not exist in that site already
          arr.push(record);
        }
        record.site = site;
      }
    }, this);
  }
});

Talho.ScriptManager.reg('Talho.VMS.CommandCenter', Talho.VMS.CommandCenter, function(config){return new Talho.VMS.CommandCenter(config);});
