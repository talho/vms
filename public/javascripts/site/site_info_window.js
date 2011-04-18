/**
 * @author Charles DuBose
 */
Ext.ns("Talho.VMS.ux");

Talho.VMS.ux.SiteInfoWindow = Ext.extend(Ext.ux.GMap.GMapInfoWindow, {
  layout: 'form',
  initComponent: function(){     
    this.record = this.record || this.marker.data.record;
    
    this.items = [{xtype: 'box', html: this.marker.data.record.get('name'), hideLabel:true},
      {xtype: 'box', html: this.record.get('address'), fieldLabel: 'Address'},
      {xtype: 'box', html: this.record.get('qualifications'), fieldLabel: 'Qualifications'},
      {xtype: 'container', height: 300, itemId: 'accordion', layout: 'accordion', hideLabel: true, items: [
        {xtype: 'grid', title: 'Staff', tools: [{id: 'gear', scope: this, handler: this.editStaff}], cls: 'staff_grid', itemId: 'staff', store: new Ext.data.JsonStore({
            fields: ['user', 'role_filled', 'roles', 'qualifications', 'user_id', 'id', 'source']
          }),
          columns: [{header: 'Name', dataIndex: 'user'}, {header: 'Role Filled', dataIndex: 'role_filled'}, {header: 'Roles', dataIndex: 'roles'}, {header: 'Qualifications', dataIndex: 'qualifications'},
                    {header: 'Source', dataIndex: 'source', renderer: function(val){switch(val){case 'manual': return 'Manually Assigned'; break; case 'team': return 'Assigned Via Team'; break; default: return 'Automatically Assigned';} } }
          ],
          listeners: {
            scope: this,
            'rowcontextmenu': this.showStaffContextMenu
          }
        },
        {xtype: 'grid', title: 'Roles', tools: [{id: 'gear', scope: this, handler: this.editRoles}], itemId: 'roles', cls: 'roles_grid', store: new Ext.data.JsonStore({
            fields: ['role', 'count', 'assigned', 'present', 'qualifications']
          }),
          columns: [{header: 'Name', dataIndex: 'role', id: 'name'}, {header: 'Required', dataIndex: 'count', width: 65}, {header: 'Assigned', dataIndex: 'assigned', width: 65}, {header: 'Present', dataIndex: 'present', width: 60}, 
                    {header: 'Qualifications', dataIndex: 'qualifications', width: 75}],
          autoExpandColumn: 'name',
          listeners: {
            scope: this,
            'rowcontextmenu': this.showRoleContextMenu
          }
        },
        {xtype: 'grid', title: 'Inventory', itemId: 'items', cls: 'inv_grid', store: new Ext.data.JsonStore({
            fields: ['name', 'quantity', 'original_quantity', 'inventory_id']
          }),
          columns: [{header: 'Item', dataIndex: 'name'}, {header: 'Quantity', dataIndex: 'quantity'}, {header: 'Starting Quantity', dataIndex: 'original_quantity'}],
          listeners: {
            scope: this,
            'rowcontextmenu': this.showInventoryContextMenu
          }
        }
      ],
      plugins: ['donotcollapseactive']}
    ];
    
    this.on('render', function(){
      if(!this.mask){
        this.mask = new Ext.LoadMask(this.getEl());
        this.mask.show();
      }
    }, this, {delay: 1});
    
    Talho.VMS.ux.SiteInfoWindow.superclass.initComponent.apply(this, arguments);
    
    var acc = this.getComponent('accordion');
    this.staffGrid = acc.getComponent('staff');
    this.rolesGrid = acc.getComponent('roles');
    this.itemsGrid = acc.getComponent('items');
    
    this.load();
  },
  
  load: function(){
    if(this.rendered){
      if(!this.mask){
        this.mask = new Ext.LoadMask(this.getEl());
      }
      this.mask.show();
    }
    
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.record.get('id') + '.json',
      method: 'GET',
      scope: this,
      callback: function(o, s, r){
        var resp = Ext.decode(r.responseText);
        if(this.mask && this.mask.hide)
          this.mask.hide();
        
        this.staffGrid.getStore().loadData(resp.staff);
        this.rolesGrid.getStore().loadData(resp.roles);
        this.itemsGrid.getStore().loadData(resp.items);
        
        this.calculateStaffAttendance(resp.staff);
        this.calculateRoleAttendance(resp.roles);
        this.calculateInventoryHealth(resp.items);
      }
    });
  },
  
  showStaffContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var loc = evt.getXY();
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    if(record.get('source') !== 'manual'){
      return;
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlighn: 'tr-br',
      items: [{text: 'Remove Staff Member', scope: this, handler: function(){
        var staff_controller = new Talho.VMS.ux.StaffController({scenarioId: this.scenarioId, siteId: this.record.get('id'), listeners: {scope: this,
          'afterremove': function(){
            this.ext_staffGrid.getStore().load();
            this.load();
          }
        }});
        Ext.Msg.confirm("Remove User", "Are you sure you wish to unassign this user from this site?", function(btn){
          if(btn === "yes"){
            this.ext_staffGrid.loadMask.show();
            staff_controller.remove(record);
          }
        }, this);
      }}]
    });
    
    if(Ext.isGecko){
      menu.showAt(loc);
    }
    else{
      menu.show(row);
    }
  },
  
  editStaff: function(){
    var staff_controller = new Talho.VMS.ux.StaffController({scenarioId: this.scenarioId, siteId: this.record.get('id'), listeners: {scope: this,
      'aftersave': function(cntrl, win){
        win.close();
        this.ext_staffGrid.getStore().load();
        this.load();
      }
    }});
    var win = new Talho.VMS.ux.CreateAndEditStaff({
      scenarioId: this.scenarioId,
      scenario_staff_store: this.ext_staffGrid.getStore(),
      siteId: this.record.get('id'),
      listeners: {
        scope: staff_controller,
        'save': staff_controller.save
      }
    });          
    win.show();
  }, 
  
  showRoleContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var loc = evt.getXY();
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    var role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, siteId: this.record.get('id'), listeners: {scope: this,
      'aftersave': function(con, win){
        win.close();
        this.ext_rolesGrid.getStore().load();
        this.load();
      }
    }});
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlighn: 'tr-br',
      items: [{text: 'Remove Role', scope: this, handler: function(){          
          var win = new Talho.VMS.ux.CreateAndEditRoles({
            removedRecord: record,
            scenarioId: this.scenarioId,
            siteId: this.record.get('id'),
            listeners: {
              scope: this,
              'save': function(win, u, r){
                win.showMask();
                role_controller.save(win, u, r);
              }
            }
          });
          win.show();
        }
      }]
    });
    
    if(Ext.isGecko){
      menu.showAt(loc);
    }
    else{
      menu.show(row);
    }
  },
  
  editRoles: function(){
     var role_controller = new Talho.VMS.ux.RolesController({scenarioId: this.scenarioId, siteId: this.record.get('id'), listeners: {scope: this,
      'aftersave': function(con, win){
        win.close();
        this.ext_rolesGrid.getStore().load();
        this.load();
      }
    }});
        
    var win = new Talho.VMS.ux.CreateAndEditRoles({
      scenarioId: this.scenarioId,
      siteId: this.record.get('id'),
      listeners: {
        scope: this,
        'save': function(win, u, r){
          win.showMask();
          role_controller.save(win, u, r);
        }
      }
    });
    win.show();
  },
  
  showInventoryContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var loc = evt.getXY();
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlighn: 'tr-br',
      items: [{text: 'Edit Inventory', scope: this, handler: function(){ 
        var win = new Talho.VMS.ux.InventoryWindow({
          scenarioId: this.scenarioId,
          inventoryId: record.get('inventory_id'),
          mode: 'edit',
          listeners: {
            scope: this,
            'save': function(win, values){   
              win.showMask();
              var inventory_controller = new Talho.VMS.ux.InventoryController({scenarioId: this.scenarioId, listeners:{ scope: this,
                'afteredit': function(cntrl, win){
                  win.close();
                  this.ext_inventoryGrid.getStore().load();
                  this.load();
                }
              }});
              inventory_controller.edit(win, values, record.get('inventory_id'), this.scenarioId);
            }
          }
        });
        
        win.show();
      }}]
    });
    
    if(Ext.isGecko){
      menu.showAt(loc);
    }
    else{
      menu.show(row);
    }
  },
  
  calculateStaffAttendance: function(staff_arr){
    var present = 0, assigned = 0, cls = '', diff;
    
    Ext.each(staff_arr, function(u){
      assigned++;
      if(u.present){
        present++;
      }
    });
    
    diff = assigned > 0 ? present/assigned : 1;
    cls = diff < 1 ? diff < .5 ? 'vms-site-info-attendance-danger' : 'vms-site-info-attendance-warning' : '';
    this.staffGrid.setTitle('Staff - <span qtip="Present" class="' + cls + '">' + present.toString() + '</span>/<span qtip="Assigned">' + assigned.toString() + '</span>');
  },
  
  calculateRoleAttendance: function(role_arr){
    var present = 0, empty_roles = 0, assigned = 0, required = 0, p_cls, a_cls, p_diff;
    
    Ext.each(role_arr, function(r){
      required++;
      if(r.assigned >= r.count)
        assigned++;
      if(r.assigned === 0 && r.count > 0)
        empty_roles++;
    });
    
    p_diff = assigned > 0 ? present/assigned : present;
    p_cls = p_diff < 1 ? p_diff < .5 ? 'vms-site-info-attendance-danger' : 'vms-site-info-attendance-warning' : '';
    a_cls = empty_roles > 0 ? 'vms-site-info-attendance-danger' : assigned < required ? 'vms-site-info-attendance-warning' : '';
    this.rolesGrid.setTitle('Roles - <span qtip="Fully Present Roles" class="' + p_cls + '">' + present.toString() + '</span>/<span qtip="Fully Assigned Roles" class="' + a_cls + '">' + assigned.toString() + '</span>/<span qtip="Number of Roles">' + required.toString() + '</span>');
  },
  
  calculateInventoryHealth: function(item_arr){
    var empty_items = 0, cls, tip;
    
    Ext.each(item_arr, function(i){
      if(i.quantity == 0)
        empty_items++;
    });
    
    cls = empty_items > 0 ? 'vms-site-info-item-danger' : '';
    tip = empty_items > 0 ? 'Inventory Unhealthy - Out of Items' : 'Inventory Healthy';
    this.itemsGrid.setTitle('Inventory <span qtip="' + tip + '" class="vms-site-info-item ' + cls + '"></span>')
  }
});
