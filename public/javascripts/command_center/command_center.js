Ext.ns("Talho.VMS");

Talho.VMS.CommandCenter = Ext.extend(Ext.Panel, {
  title: 'VMS Command Center',
  closable: true,
  layout: 'border',
  
  constructor: function(config){
    if(Application.rails_environment == 'cucumber') this.itemId = 'vms_command_center';
    
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
            case 'assigned':
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
            case 'qual': cls += 'vms-qual';
              break;
            case 'team': cls += 'vms-team';
              break;
            case 'checked_in_team': cls += 'vms-checked-in-team';
              break;
            case 'auto_user': cls += 'vms-auto-user';
              break;
            case 'staff': cls += 'vms-manual-user';
              break;
            case 'checked_in_staff': cls += 'vms-checked-in-user';
              break;
            case 'walkup': cls += 'vms-walkup';
              break;
            case 'checked_in_walkup': cls += 'vms-checked-in-walkup';
              break;
            case 'checked_in_user': cls += 'vms-checked-in-user';
              break;
          }
          
          return cls;
        }
    });
    
    var vms_tool_grid = Ext.extend(Ext.grid.GridPanel, {
      hideHeaders: true, enableDragDrop: true, ddGroup: 'vms',
      loadMask: true,
      command_center: this,
      bodyCssClass: 'vms-tool-grid',
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
        this.on('afterrender', this.command_center.initToolGridDropTarget, this.command_center, {delay: 1});
        this.getStore().on('load', this.add_default_rows, this);
      },
      add_default_rows: function(store){
        if(!this.command_center.can_edit){
          return;
        }
        
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
      processEvent: function(name, e){
        Ext.grid.GroupingView.superclass.processEvent.call(this, name, e);
        var hd = e.getTarget('.x-grid-group-hd', this.mainBody);
        if(hd){
            // group value is at the end of the string
            var field = this.getGroupField(),
                prefix = this.getPrefix(field),
                groupValue = hd.id.substring(prefix.length),
                emptyRe = new RegExp('gp-' + Ext.escapeRe(field) + '--hd'),
                s, dd;

            // remove trailing '-hd'
            groupValue = groupValue.substr(0, groupValue.length - 3);
            
            // also need to check for empty groups
            if(groupValue || emptyRe.test(hd.id)){
                this.grid.fireEvent('group' + name, this.grid, field, groupValue, e);
            }
            if(name == 'click' && e.button == 0){
                this.toggleGroup(hd.parentNode);
            }
            else if(name == 'mousedown' && e.button == 0){
              s = Ext.get(hd).down('.x-grid-group-title');
              if(!Ext.dd.DDM.isDragDrop(s.id)){
                dd = new Ext.dd.DragSource(s, {ddGroup: 'vms', dragData: groupValue});
                dd.handleMouseDown(e);
              }
            }
        }
      },
    
      startGroup: new Ext.XTemplate(
        '<div id="{groupId}" class="x-grid-group {cls}" unselectable="on" style="-moz-user-select:none;user-select:none;">',
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
        { title: 'Controls', itemId: 'controlPanel', cls: 'controlPanel', layout: 'anchor', autoScroll: true, 
          defaults: {anchor: '100%'}, items: [
            {xtype: 'actionbutton', itemId: 'executeBtn', text: 'Execute', scope: this, handler: this.beginExecution, iconCls: 'vms-control-play'},
            {xtype: 'actionbutton', itemId: 'pauseBtn', text: 'Pause Execution', hidden: true, scope: this, handler: this.pauseExecution, iconCls: 'vms-control-pause'},
            {xtype: 'actionbutton', itemId: 'endBtn', text: 'End Scenario', hidden: true, scope: this, handler: this.endExecution, iconCls: 'vms-control-stop'},
            {xtype: 'actionbutton', text: 'Edit Scenario', scope: this, handler: this.editScenario, iconCls: 'vms-control-edit'},
            {xtype: 'actionbutton', text: 'Alert Staff', scope: this, handler: this.alertStaff, iconCls: 'vms-control-alert' }
          ]
        },
        { title: 'Sites', itemId: 'siteGrid', cls: 'siteGrid', xtype: 'vms-toolgrid', tools: tool_cfg, seed_data: {name: 'New Site (drag to create)', status: 'new', type: 'site'},
          store: new tool_store({
            reader: new Ext.data.JsonReader({
              root: 'sites',
              idProperty: 'site_id',
              fields: [
                {name:'name', mapping:'site.name'},
                {name: 'type', defaultValue:'site'},
                {name:'status', convert: function(v){return v == 2 ? 'active': 'inactive';} },
                {name: 'address', mapping: 'site.address'},
                {name: 'lat', mapping: 'site.lat'},
                {name: 'lng', mapping: 'site.lng'},
                {name: 'id', mapping: 'site_id'}, 'qualifications']
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
            groupField: 'site_id'
          }),
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
        {title: 'Roles', xtype: 'vms-toolgrid', tools: tool_cfg, itemId: 'roles_grid', cls: 'roleGrid', seed_data: {name: 'Add Role (drag to site)', type: 'role', status: 'new'},
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
            groupField: 'site_id'
          }),
          view:  new tool_grouping_view()
        },
        {title: 'Qualifications', xtype: 'vms-toolgrid', tools: tool_cfg, itemId: 'quals_grid', cls: 'qualGrid', seed_data: {name: 'Add Qualification (drag to site)', type: 'qual', status: 'new'},
          columns: [{xtype: 'templatecolumn', id: 'name_column', tpl: new Ext.XTemplate(
            '<div class="vms-tool-row">',
              '<div class="vms-row-icon {[this.iconClass(values)]}"></div>',
              '<div class="vms-row-text">{[this.val(values)]}</div>',
              '<div style="clear:both;"></div>',
            '</div>',
            {
              compiled: true,
              iconClass: this.row_template.iconClass,
              val: function(values){
                var ret = values.name;
                if(values.role) ret += " - " + values.role;
                return ret;
              }
            }
        )}, 
        {dataIndex: 'site_id', hidden: true}],
          listeners:{
            scope: this,
            'rowcontextmenu': this.showQualsContextMenu
          },
          store: new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
              fields: ['name', {name: 'type', defaultValue: 'qual'}, {name: 'status', defaultValue: 'active'}, 'role', 'role_id', 'site_id', 'site']
            }),
            type: 'role',
            url: '/vms/scenarios/' + config.scenarioId + '/qualifications',
            groupField: 'site_id'
          }),
          view:  new tool_grouping_view()
        },
        {title: 'Teams', xtype: 'vms-toolgrid', cls: 'vms_teams_grid', tools: tool_cfg, itemId: 'teams_grid', seed_data: {name: 'New Team (drag to site)', type: 'team', status: 'new'},
          columns: [{xtype: 'templatecolumn', id: 'name_column', tpl: this.row_template}, {dataIndex: 'site_id', hidden: true}],
          listeners: {
            scope: this,
            'rowcontextmenu': this.showTeamContextMenu
          },
          store: new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
              idProperty: 'id', 
              fields: ['name', {name: 'type', convert: function(v, r){
                if ( r.all_checked_in ){ return 'checked_in_team'; } else { return 'team'; }
              }}, {name: 'status', defaultValue: 'active'}, 'id', 'site_id', 'site', {name: 'user_count', type: 'integer'}]
            }),
            type: 'team',
            url: '/vms/scenarios/' + config.scenarioId + '/teams',
            groupField: 'site_id'
          }),
          view: new tool_grouping_view()
        },
        {title: 'Staff', xtype: 'vms-toolgrid', itemId: 'staff_grid', tools: tool_cfg, cls: 'staffGrid', seed_data: {name: 'Add User (drag to site)', type: 'staff', status: 'new'},
          columns: [{xtype: 'templatecolumn', id:'name_column', tpl: this.row_template }, {dataIndex: 'site_id', hidden: true}],
          listeners:{
            scope: this,
            'rowcontextmenu': this.showStaffContextMenu,
            'groupcontextmenu': this.showStaffGroupContextMenu
          },
          store: new Ext.data.GroupingStore({
            reader: new Ext.data.JsonReader({
              idProperty: 'id',
              fields: [{name: 'name', mapping: 'user'}, {name: 'type', defaultValue: 'staff', convert: function(v, r){
                switch(r.source){
                  case 'team':
                  case 'auto': if ( r.checked_in ){ return 'checked_in_staff';} else { return 'auto_user'; }
                  case 'walkup' : if ( r.checked_in ){ return 'checked_in_walkup';} else { return 'walkup'; }
                  case 'manual':
                  default: if ( r.checked_in ){ return 'checked_in_staff';} else { return 'staff'; }
                }
              }}, {name: 'status'}, 'source', 'id', 'site_id', 'site', 'user_id']
            }),
            type: 'staff',
            url: '/vms/scenarios/' + config.scenarioId + '/staff',
            groupField: 'site_id'
          }),
          view:  new tool_grouping_view()
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
    this.qualsGrid = this.eastRegion.getComponent('quals_grid');
    this.teamsGrid = this.eastRegion.getComponent('teams_grid');
    this.staffGrid = this.eastRegion.getComponent('staff_grid');
    this.map = this.getComponent('map');
    this.controlPanel = this.westRegion.getComponent('controlPanel');
    this.executeBtn = this.controlPanel.getComponent('executeBtn');
    this.pauseBtn = this.controlPanel.getComponent('pauseBtn');
    this.endBtn = this.controlPanel.getComponent('endBtn');
    
    this.initControllers();
    
    // Ext.Ajax.request({
      // url: '/vms/scenarios/' + this.scenarioId,
      // method: 'GET',
      // success: this.loadScenario_success,
      // scope: this
    // });
    
    this.buildPollingProvider();
    
    this.on('afterrender', function(){
      if(!this.initial_load_complete){
        this.loadMask = new Ext.LoadMask(this.getLayoutTarget());
        this.loadMask.show();
      }
    }, this, {delay: 1});
  },
  
  buildPollingProvider: function(){
    Ext.Direct.addProvider({
      type: 'polling',
      url: '/vms/scenarios/' + this.scenarioId,
      id: 'command_center_polling_provider-' + this.scenarioId,
      interval: 15000,
      listeners: {
        scope: this,
        beforepoll: function(){
          return true;
        },
        data: function(pp, evt){
          this.loadScenario_success(evt);
        }
      }
    });
  },
  
  destroy: function(){
    Ext.Direct.getProvider('command_center_polling_provider-' + this.scenarioId).disconnect();
    Talho.VMS.CommandCenter.superclass.destroy.apply(this, arguments);
  },
  
  initControllers: function(){
    this.role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, listeners: { scope: this,
      'aftersave': function(controller, win){
        win.close();
        this.rolesGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      }
    }});
    
    this.staff_controller = new Talho.VMS.ux.StaffController({scenarioId: this.scenarioId, listeners: {scope: this,
      'aftersave': function(cntrlr, win){
        win.close();
        this.staffGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      },
      'afterremove': function(cntrlr){
        this.staffGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      },
      'aftermove': function(cntrlr){
        this.staffGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      }
    }});
    
    this.inventory_controller = new Talho.VMS.ux.InventoryController({scenarioId: this.scenarioId, listeners:{ scope: this,
      'aftercreate': function(cntrl, win){
        win.close();
        this.inventoryGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();        
      },
      'afteredit': function(cntrl, win){
        win.close();
        this.inventoryGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      },
      'afterdestroy': function(cntrl){
        this.inventoryGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      },
      'aftermove': function(cntrl){
        this.inventoryGrid.getStore().load();
        if(this.current_site_info_window) this.current_site_info_window.load();
      }
    }});
  },
  
  loadScenario_success: function(response, options){
    this.initial_load_complete = true;
    if(this.loadMask) this.loadMask.hide();
    
    var result = response;
    if(response.responseText)
      result = Ext.decode(response.responseText);
    
    this.scenarioName = result.name;
    this.setTitle('Command Center - ' + this.scenarioName);
    
    switch(result.state){
      case 1: this.scenario_state = 'template';
        break;
      case 2: this.scenario_state = 'unexecuted';
        break;
      case 3: this.scenario_state = 'executing';
        break;
      case 4: this.scenario_state = 'paused';
        break;
      case 5: this.scenario_state = 'ended';
        break;
    }
    this.updateState();
    
    this.can_edit = result.can_admin && this.scenario_state !== 'ended';
    // If the user cannot edit the scenario, lock the map and all of the toolset grids from allowing drag/drop
    if(!this.can_edit){
      this.map.dropZone.lock();
      this.siteGrid.getView().dragZone.lock();
      this.inventoryGrid.getView().dragZone.lock();
      this.rolesGrid.getView().dragZone.lock();
      this.qualsGrid.getView().dragZone.lock();
      this.teamsGrid.getView().dragZone.lock();
      this.staffGrid.getView().dragZone.lock();
      this.controlPanel.hide();
      this.westRegion.getLayout().setActiveItem(1);
    }
    
    this.siteGrid.getStore().loadData({sites: result.site_instances});
    this.inventoryGrid.getStore().loadData(result.inventories);
    this.rolesGrid.getStore().loadData(result.roles);
    this.qualsGrid.getStore().loadData(result.qualifications);
    this.teamsGrid.getStore().loadData(result.teams);
    this.staffGrid.getStore().loadData(result.all_staff);
    
    delete result.site_instances;
    delete result.inventories;
    delete result.roles;
    delete result.qualifications;
    delete result.teams;
    delete result.all_staff;
    result = null;
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
        if(data.selections && data.selections[0].get('type') == 'site')
          return this.dropNotAllowed;
        else if(!data.selections){
          var marker = this.parent.map.getCurrentHover();
          if(marker && marker.data && marker.data.record && data === marker.data.record.get('id').toString())
            return this.dropNotAllowed;
          else
            return this.dropAllowed;
        }
        else
          return this.dropAllowed;
      },
            
      onContainerOver: function(dd, e, data){ 
        if(data.selections && data.selections[0].get('type') == 'site')
          return this.dropAllowed;
        else
          return this.dropNotAllowed;
      },
      
      onNodeDrop: function(target, dd, e, data){
        var rec = data.selections ? data.selections[0] : null;
        
        
        if(rec && rec.get('type') == 'site'){
          return false;
        }
        
        var marker = this.parent.map.getCurrentHover();
        
        if(dd.grid.getStore().type == 'role' && !rec && marker && marker.data && marker.data.record){
          this.parent.copyRolesToSite(data, marker.data.record);
          return true;
        }
        
        if(marker && marker.data && marker.data.record){
          this.parent.addItemToSite(marker.data.record, rec);
          return true;
        }
        else
          return false;
      },
      
      onContainerDrop: function(dd, e, data, forceLatLng){
        if(data.selections && data.selections[0].get('type') == 'site'){
          this.parent.addSiteToMap((forceLatLng && forceLatLng.lat) ? new google.maps.LatLng(forceLatLng.lat, forceLatLng.lng) : this.parent.map.getCurrentLatLng(), data.selections[0]);
          return true;
        }
        else{
          return false;
        }
      }
    });
  },
  
  initToolGridDropTarget: function(grid){
    grid.dropTarget = new Ext.dd.DropTarget(grid.getView().mainBody, {
      parent: this,
      ddGroup: 'vms',
      grid: grid,
      canDrop: function(source, e, data){
        if(Ext.isString(data) || data.rowIndex === undefined)
          return false;
          
        var rec = data.grid.getStore().getAt(data.rowIndex), 
            group_tar = e.getTarget('.x-grid-group'),
            row_index = this.grid.getView().findRowIndex(e.target),
            drop_rec = this.grid.getStore().getAt(row_index),
            site_id;
        
        if(this.grid.getStore().type == 'site' && rec.get('type') == 'site')
          return false;

        if(this.grid.getStore().type !== 'site' && this.grid !== data.grid)
          return false;
          
        if(drop_rec && drop_rec.get('status') == 'new')
          return false;

        if(row_index === false){
          if(!group_tar)
            return false;
          site_id = group_tar.id.replace(/^ext-gen(\d*)-gp-site_id-/, '')
        }
        else
          site_id = drop_rec.get('type') == 'site' ? drop_rec.get('id') : drop_rec.get('site_id');
        
        if(site_id == undefined)
          return false;
        
        var type = rec.get('type')
        if(rec.get('site_id') == site_id && type !== 'role' && type !== 'staff')
          return false;
          
        return site_id;
      },
      notifyDrop: function(source, e, data){
        var site_id = this.canDrop(source, e, data);
        if(site_id === false) return false;
        rec = data.grid.getStore().getAt(data.rowIndex)
        var site_rec = this.parent.siteGrid.getStore().getById(site_id);
        this.parent.addItemToSite(site_rec, rec);
        return true;
      },
      notifyOver: function(source, e, data){
        return this.canDrop(source, e, data) === false ? this.dropNotAllowed : this.dropAllowed;
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
    switch(record.get('type')){
      case 'inventory':
      case 'pod': this.addInventoryToSite(record, site);
        break;
      case 'role': this.addRoleToSite(record, site);
        break;
      case 'team': this.addTeamToSite(record, site);
        break;
      case 'staff': this.addUserToSite(record, site);
        break;
      case 'qual': this.addQualificationToSite(record, site);
        break;
    }    
  },
  
  showSiteMarkerInfo: function(marker){  
    this.current_site_info_window = new Talho.VMS.ux.SiteInfoWindow({
      marker: marker,
      can_edit: this.can_edit,
      cls: 'site_info_window',
      scenarioId: this.scenarioId,
      ext_rolesGrid: this.rolesGrid,
      ext_staffGrid: this.staffGrid,
      ext_siteGrid: this.siteGrid,
      ext_inventoryGrid: this.inventoryGrid,
      listeners: { scope: this,
        'destroy': function(){
          this.current_site_info_window = null;
        }
      }
    });
    this.current_site_info_window.show();
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
  },
  
  findMarker: function(record){
    var marker = null;
    Ext.each(this.map.markers, function(m){ if(m.data.record.id === record.id){
      marker = m;
      return false;
    }});
    return marker;
  }
});

Ext.override(Talho.VMS.CommandCenter, Talho.VMS.ux.CommandCenter.ContextMenus);
Ext.override(Talho.VMS.CommandCenter, Talho.VMS.ux.CommandCenter.SiteApplications);
Ext.override(Talho.VMS.CommandCenter, Talho.VMS.ux.CommandCenter.ScenarioStatus);

Talho.ScriptManager.reg('Talho.VMS.CommandCenter', Talho.VMS.CommandCenter, function(config){return new Talho.VMS.CommandCenter(config);});
