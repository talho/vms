Ext.ns("Talho.VMS");

Talho.VMS.CommandCenter = Ext.extend(Ext.Panel, {
  title: 'VMS Command Center',
  closable: true,
  layout: 'border',
  itemId: 'vms_command_center',
  
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
    
    var tool_grouping_view = Ext.extend(Ext.grid.GroupingView, {enableGroupingMenu: false, showGroupName: 'false',
      startGroup: new Ext.XTemplate(
        '<div id="{groupId}" class="x-grid-group {cls}">',
          '<div id="{groupId}-hd" class="{[this.getHDClass(values)]}" style="{style}"><div class="x-grid-group-title">', "{[this.getText(values)]}" ,'</div></div>',
          '<div id="{groupId}-bd" class="x-grid-group-body">', {
            compiled: true,
            getHDClass: function(val){
              return Ext.isEmpty(val.group) ? 'x-grid-group-hd-empty' : 'x-grid-group-hd';
            },
            getText: function(val){
              return Ext.isEmpty(val.group) ? '' : val.rs[0].get('site');
            }
          }
      )
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
          bodyCssClass: 'google_map',
          xtype: 'gmappanel',
          zoomLevel: 10,
          gmapType: 'map',
          mapConfOpts: ['enableScrollWheelZoom','enableDoubleClickZoom','enableDragging'],
          mapControls: ['GSmallMapControl','GMapTypeControl','NonExistantControl'],
          setCenter: {
              geoCodeAddr: 'Austin, Tx, USA'
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
        { title: 'Sites', itemId: 'siteGrid', cls: 'siteGrid', xtype: 'vms-toolgrid', tools: tool_cfg, seed_data: {name: 'New Site (drag to create)', status: 'new', type: 'site'},
          store: new tool_store({
            reader: new Ext.data.JsonReader({
              root: 'sites',
              idProperty: 'site_id',
              fields: [{name:'name', mapping:'site.name'}, {name: 'type', defaultValue: 'site'}, {name:'status', convert: function(v){return v == 2 ? 'active': 'inactive';} }, {name: 'address', mapping: 'site.address'}, {name: 'lat', mapping: 'site.lat'}, {name: 'lng', mapping: 'site.lng'}, {name: 'id', mapping: 'site_id'}]
            }),
            type: 'site',
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
        {title: 'PODs/Inventories', xtype: 'vms-toolgrid', cls: 'inventoryGrid', tools: tool_cfg, itemId: 'inventory_grid', seed_data: {name: 'New POD/Inventory (drag to site)', type: 'inventory', status: 'new'},
          store: new Talho.VMS.ux.InventoryController.inventory_list_store({ scenarioId: config.scenarioId, type: 'inventory',
            groupField: 'site_id',
            listeners: {
              scope: this,
              'load': this.applyToSite
          } }),
          columns: [{xtype: 'templatecolumn', id: 'name_column', tpl: this.row_template}, {dataIndex: 'site_id', hidden: true}],
          view: new tool_grouping_view(),
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
        {title: 'Roles', xtype: 'vms-toolgrid', itemId: 'roles_grid', cls: 'roleGrid', seed_data: {name: 'Add Role (drag to site)', type: 'role', status: 'new'},
          columns: [{xtype: 'templatecolumn', id: 'name_column', tpl: this.row_template}, {dataIndex: 'site_id', hidden: true}],
          listeners:{
            scope: this,
            'rowcontextmenu': this.showRolesContextMenu,
            'groupcontextmenu': this.showRolesGroupContextMenu
          },
          store: new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
              idProperty: 'id',
              fields: [{name: 'name', mapping: 'role'}, {name: 'type', defaultValue: 'role'}, {name: 'status', defaultValue: 'active'}, 'id', 'site_id', 'site', 'role_id', {name: 'count', type: 'integer'}]
            }),
            type: 'role',
            url: '/vms/scenarios/' + config.scenarioId + '/roles',
            listeners:{
              scope: this,
              'load': this.applyToSite
            },
            groupField: 'site_id'
          }),
          view:  new tool_grouping_view()
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
    this.rolesGrid.getStore().load();
    this.teamsGrid.getStore().loadData([]);
    this.staffGrid.getStore().loadData([]);
  },
  
  initMapDropZone: function(){
    this.map.dropZone = new Ext.dd.DropZone(this.map.getEl(), {
      parent: this,
      ddGroup: 'vms',
      
      getTargetFromEvent: function(e){
        var target = e.getTarget('div');
        if(this.parent.map.getCurrentHover()){
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
        
        var marker = this.parent.map.getCurrentHover();
        if(marker && marker.data && marker.data.record){
          this.parent.addItemToSite(marker.data.record, rec);
          return true;
        }
        else
          return false;
      },
      
      onContainerDrop: function(dd, e, data, forceLatLng){
        if(data.selections[0].get('type') == 'site'){
          this.parent.addSiteToMap((forceLatLng && forceLatLng.lat) ? new google.maps.LatLng(forceLatLng.lat, forceLatLng.lng) : this.parent.map.getCurrentLatLng(), data.selections[0]);
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
    var site_controller = new Talho.VMS.ux.SiteController({scenarioId: this.scenarioId, map: this.map, store: this.siteGrid.getStore()});
    var win = new Talho.VMS.ux.CreateAndEditSite({
      record: record,
      latLng: latLng,
      map: this.map,
      scenarioId: this.scenarioId,
      recordType: this.siteGrid.getStore().recordType,
      listeners:{
        scope: site_controller,
        'save': site_controller.create
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
    
    switch(record.get('type')){
      case 'inventory':
      case 'pod': this.addInventoryToSite(record, site);
        break;
      case 'role': this.addRoleToSite(record, site, prep_record, init_record);
        break;
      case 'team': this.addTeamToSite(record, site, prep_record, init_record);
        break;
      case 'manual_user': this.addManualUserToSite(record, site, prep_record, init_record);
        break;
      case 'auto_user': this.addAutoUserToSite(record, site, prep_record, init_record);
        break;
      default: record = prep_record(record);
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
        var site_controller = new Talho.VMS.ux.SiteController({scenarioId: this.scenarioId, map: this.map, store: this.siteGrid.getStore()});
        var win = new Talho.VMS.ux.CreateAndEditSite({
          record: record,
          scenarioId: this.scenarioId,
          mode: 'edit',
          map: this.map,
          listeners:{
            'save': site_controller.edit.createDelegate(site_controller, [this.findMarker(record)], true)
          }      
        });
        
        win.show();
      }},
      {text: 'Remove', scope: this, handler: function(){
        var site_controller = new Talho.VMS.ux.SiteController({scenarioId: this.scenarioId, map: this.map, store: this.siteGrid.getStore()});
        site_controller.destroy(record, this.findMarker(record));
      }}
    ];
    
    if(record.get('status') === 'active'){
      menuConfig.push({text: 'Deactivate', scope: this, handler: function(){
        var site_controller = new Talho.VMS.ux.SiteController({scenarioId: this.scenarioId, map: this.map});
        site_controller.deactivate(record, this.findMarker(record));
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
        Ext.Msg.confirm('Confirm Deletion', 'Are you sure you wish to delete the ' + record.get('name') + ' POD/Inventory? This action cannot be undone.', function(btn){
          if(btn === 'yes')
            Talho.VMS.ux.InventoryController.destroy(record, this.scenarioId, grid.getStore());
        }, this)
      }}
    ];
    // later add in the ability to have inactive inventories already assigned to sites
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  showRolesContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    if(record.get('status') === 'new'){
      return;
    }

    var role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, siteId: record.get('site_id'), store: this.rolesGrid.getStore()});
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items:[{
        text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditRoles({
            scenarioId: this.scenarioId,
            siteId: record.get('site_id'),
            listeners: {
              scope: role_controller,
              'save': role_controller.save
            }
          });
          win.show();
        }
      }, {
        text: 'Remove', scope: this, handler: function(){          
          var win = new Talho.VMS.ux.CreateAndEditRoles({
            removedRecord: record,
            scenarioId: this.scenarioId,
            siteId: record.get('site_id'),
            listeners: {
              scope: role_controller,
              'save': role_controller.save
            }
          });
          win.show();
        }
      }]
    });
    
    menu.show(row);    
  },
  
  showRolesGroupContextMenu: function(grid, field, value, evt){
    evt.preventDefault(); 
    var elem = evt.getTarget();
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items:[{
        text: 'Edit', scope: this, handler: function(){
          var role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, siteId: value, store: this.rolesGrid.getStore()});
          var win = new Talho.VMS.ux.CreateAndEditRoles({
            scenarioId: this.scenarioId,
            siteId: value,
            listeners: {
              scope: role_controller,
              'save': role_controller.save
            }
          });
          win.show();
        }
      }]
    });
    
    menu.show(elem);
  },
  
  findMarker: function(record){
    var marker = null;
    Ext.each(this.map.markers, function(m){ if(m.data.record.id === record.id){
      marker = m;
      return false;
    }});
    return marker;
  },
  
  /**
   * Applies the records in the record array to the sites already loaded in the site grid
   * @param {Ext.data.Store}  store   The source store of the records. Checks for a property, "type" on the store to determine if it should clear the current sites
   * @param {Array}           records The records that were loaded into the store
   * @param {Object}          opts    The options for the load command. What we're looking for here is the 'keepExisting' option, which will let us determine if we really want to clear off the records
   */
  applyToSite: function(store, records, opts){
    if(!opts.keepExisting && store.type) this.clearOldAppliedRecords(store.type);
    Ext.each(records, function(record){      
      var site = this.siteGrid.getStore().getById(record.get('site_id'));
      if(site){
        var type = record.get('type');
        type = type === 'pod' ? 'inventory' : type; // show inventory and pod as the same thing
        
        if(!site.get(type))
          site.set(type, []); // initialize an empty array for the type that we just dragged onto this site
        var arr = site.get(type);
        
        var mc = new Ext.util.MixedCollection();
        mc.addAll(arr);
        if(arr.indexOf(record) == -1){ // only add if the item does not exist in that site already
          var rec = mc.find(function(i){return i.id === record.id;});
          if(rec){
            arr.remove(rec);
          }
          arr.push(record);
        }
        record.site = site;
      }
    }, this);
  },
  
  /**
   * Clears records that were applied to the array of the given type. This is used to reapply the records to the sites after that record's grid has been reloaded
   * @param   {String}  type  The type of record that we want to clear from the site
   * @return                  NOTHING
   */
  clearOldAppliedRecords: function(type){
    var siteStore = this.siteGrid.getStore();
    siteStore.each(function(site){
      var typeArr = site.get(type);
      while(typeArr && typeArr.length > 0){
        var tObj = typeArr.pop();
        delete tObj.site;
      }
    }, this);
  },
  
  addInventoryToSite: function(record, site){
    var inv_cntrl = Talho.VMS.ux.InventoryController;
    var inv_win_fn = function(){        
      var win = new Talho.VMS.ux.InventoryWindow({
        scenarioId: this.scenarioId,
        record: record,
        listeners: {
          'save': inv_cntrl.create.createDelegate(inv_cntrl, [record, this.scenarioId, site, this.inventoryGrid.getStore()], true) 
        }
      });
      win.show();
    }.createDelegate(this);
    
    if(record.get('status') === 'new'){
      inv_win_fn();
    }
    else{
      Ext.Msg.show({
        title: 'Move or Copy POD/Inventory',
        msg: 'Would you like to move this POD/Inventory or copy it to the location?',
        buttons: {yes: 'Move', no: 'Copy'},
        scope: this,
        fn: function(btn){
          if(btn === 'yes'){
            inv_cntrl.move(record, this.scenarioId, site, this.inventoryGrid.getStore());
          }
          else if(btn === 'no'){
            inv_win_fn();
          }
        }        
      });
    }
  },
  
  addRoleToSite: function(record, site, prep_record, init_record){    
    var role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, siteId: site.id, store: this.rolesGrid.getStore()});
    var win = new Talho.VMS.ux.CreateAndEditRoles({
      creatingRecord: record,
      scenarioId: this.scenarioId,
      siteId: site.id,
      listeners: {
        scope: role_controller,
        'save': role_controller.save
      }
    });
    win.show();
  },
  
  addTeamToSite: function(record, site, prep_record, init_record){
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
  },
  
  addManualUserToSite: function(record, site, prep_record, init_record){
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
  },
  
  addAutoUserToSite: function(record, site, prep_record, init_record){
    if(record.get('status') === 'active' && record.site)
      record.site.get('auto_user').remove(record);// remove the user from his current site
    init_record(record);
    record.site = site;
  }
});

Talho.ScriptManager.reg('Talho.VMS.CommandCenter', Talho.VMS.CommandCenter, function(config){return new Talho.VMS.CommandCenter(config);});
