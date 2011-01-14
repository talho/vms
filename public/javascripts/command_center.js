Ext.ns("Talho.VMS");

Talho.VMS.CommandCenter = Ext.extend(Ext.Panel, {
  title: 'VMS Command Center',
  closable: true,
  layout: 'border',
  
  constructor: function(){
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
      }
    });
    
    Ext.reg('vms-toolgrid', vms_tool_grid);
    
    var tool_store = Ext.extend(Ext.data.Store, {
      reader: new Ext.data.JsonReader({fields: ['name', 'type', 'status', 'address']})
    });
    
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
        { title: 'Site', itemId: 'siteGrid', xtype: 'vms-toolgrid',
          store: new tool_store({data: [{name: 'New Site (drag to create)', status: 'new', type: 'site'}, {name: 'Immunization Center 1', status: 'inactive', type: 'site'}, {name: 'FBC', status: 'inactive', type: 'site', address: '706 Newsom Ave, Lufkin, TX 75904, USA'}]})
        },
        {title: 'PODS/Inventory', xtype: 'vms-toolgrid', itemId: 'inventory_grid', 
          store: new tool_store({data: [{name: 'New POD/Inventory (drag to site)', type: 'inventory', status: 'new'}, {name: 'Hurricane Pack', status: 'inactive', type: 'inventory' }, {name: 'Foodborn Pathogen Response POD', status: 'inactive', type: 'pod'}]})
        }
      ], plugins: ['donotcollapseactive'], width: 200, split: true },
      { xtype: 'container', itemId: 'eastRegion', region: 'east', layout: 'accordion', items:[
        {title: 'Exigency Profile', xtype: 'vms-toolgrid',
          store: new tool_store({data: [{name: 'Immunization Outbreak Profile', type: 'profile', status: 'inactive'}, {name: 'Hurrican Response Profile', type: 'profile', status: 'inactive'}]})
        },
        {title: 'Roles', xtype: 'vms-toolgrid', itemId: 'roles_grid',
          store: new tool_store({data: [{name: 'Add Role (drag to site)', type: 'role', status: 'new'}, {name: 'Health and Alert Communication Coordinator', type: 'role', status: 'inactive'}]})
        },
        {title: 'Teams', xtype: 'vms-toolgrid', itemId: 'teams_grid',
          store: new tool_store({data: [{name: 'New Team (drag to site)', type: 'team', status: 'new'}]})
        },
        {title: 'Staff', xtype: 'vms-toolgrid', itemId: 'staff_grid',
          store: new tool_store({data: [{name: 'Add User (drag to site)', type: 'manual_user', status: 'new'}]})
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
  },
  
  addSite: function(){
    var store = this.siteGrid.getStore();
    store.add(new store.recordType({name: 'Site', status: 'active', type: 'single_site'}));
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
          // if(!marker.data.record.get(rec.get('type')))
          //   marker.data.record.set(rec.get('type'), []);
          // var arr = marker.data.record.get(rec.get('type'));
          // 
          // if(arr.indexOf(rec) == -1){
          //   arr.push(rec);
          // }  
          return true;
        }
        else
          return false;
      },
      
      onContainerDrop: function(dd, e, data){
        if(data.selections[0].get('type') == 'site'){
          this.parent.addSiteToMap(this.map.getCurrentLatLng(), data.selections[0]);
          //this.map.addMarker(this.map.getCurrentLatLng(), data.selections[0].get('name'), {record: data.selections[0]});
          return true;
        }
        else{
          return false;
        }
      }
    });
  },
  
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

    var win = new Talho.VMS.ux.ItemDetailWindow({
      items: [
        {xtype: 'textfield', itemId: 'name_field', fieldLabel: 'Name', value: mode != 'new' ? (mode == 'copy' ? 'Copy of ' : '') + record.get('name') : 'New Site Name' },
        {xtype: 'textfield', itemId: 'address_field', fieldLabel: 'Address', value: original_address}
      ],
      listeners:{
        scope: this,
        'save': function(win){
          var store = this.siteGrid.getStore();
          var addr = win.getComponent('address_field').getValue();
          
          var rec = mode == 'activate' ? record : new store.recordType({name: win.getComponent('name_field').getValue(), status: 'active', type: 'site', address: addr});
          if(mode != 'activate')
            store.add(rec);
          else
            rec.set('status', 'active');
          
          var add_marker_local = function(loc){
            this.map.addMarker(loc, rec.get('name'), {record: rec});
            win.close();
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
        rec = record.copy();
        rec.id = Ext.data.Record.id(rec);
        this.addItemToTypeStore(rec);
      }
      return rec;
    }.createDelegate(this);
    
    if(record.get('type') == 'inventory' || record.get('type') == 'pod'){
      var win = new Talho.VMS.ux.InventoryWindow({
        record: record,
        listeners: {
          scope: this,
          'save': function(win, name, type){
            record = prep_record(record);
            record.set('name', name);
            record.set('type', type);
            init_record(record);
            record.site = site;
            win.close();
          }
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
  }
});

Talho.ScriptManager.reg('Talho.VMS.CommandCenter', Talho.VMS.CommandCenter, function(){return new Talho.VMS.CommandCenter();});
