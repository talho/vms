/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux.CommandCenter');

Talho.VMS.ux.CommandCenter.ContextMenus = {
  showSiteContextMenu: function(grid, row_index, evt){
    evt.preventDefault();

    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
    
    if(record.get('status') === 'new'){
      return;
    }
    
    if(this.can_edit){
      menuConfig = [
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
          site_controller.deactivate(record, this.findMarker(record), grid);
        }});
      }
    }
    
    menuConfig.push({
      text: 'Show Site Information', scope: this, handler: function(){
        var marker = this.findMarker(record);
        this.showSiteMarkerInfo(marker);
      }
    })
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  showInventoryContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
    
    if(record.get('status') === 'new'){
      return;
    }
    
    if(this.can_edit){
      menuConfig = [
        {text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.InventoryWindow({
            scenarioId: this.scenarioId,
            record: record,
            mode: 'edit',
            listeners: {
              scope: this,
              'save': function(win, values){
                win.showMask();
                this.inventory_controller.edit(win, values, record, this.scenarioId);
              }
            }
          });
          
          win.show();
        }},
        {text: 'Delete', scope: this, handler: function(){
          Ext.Msg.confirm('Confirm Deletion', 'Are you sure you wish to delete the ' + record.get('name') + ' POD/Inventory? This action cannot be undone.', function(btn){
            if(btn === 'yes'){
              grid.loadMask.show();
              this.inventory_controller.destroy(record, this.scenarioId);
            }
          }, this)
        }}
      ];
      // later add in the ability to have inactive inventories already assigned to sites
    }
    else{
      menuConfig = { text: 'View Details', scope: this, handler: function(){
        var win = new Talho.VMS.ux.InventoryWindow({
            scenarioId: this.scenarioId,
            record: record,
            can_edit: false,
            mode: 'show'
          });
          
          win.show();
      }}
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  showRolesContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
        
    if(record.get('status') === 'new'){
      return;
    }
    this.role_controller.siteId = record.get('site_id');
  
    var save_fn = function(win, u, r){
      win.showMask();
      this.role_controller.save(win, u, r);
    };
    
    var show_win_fn = function(removedRecord){
      var win = new Talho.VMS.ux.CreateAndEditRoles({
        removedRecord: removedRecord,
        scenarioId: this.scenarioId,
        readOnly: !this.can_edit,
        siteId: record.get('site_id'),
        listeners: {
          scope: this,
          'save': save_fn
        }
      });
      win.show();
    }
    
    if(this.can_edit){
      menuConfig = [{
        text: 'Edit', handler: show_win_fn.createDelegate(this, [null])
      }, {
        text: 'Remove', handler: show_win_fn.createDelegate(this, [record])
      }];
    }
    else
    {
      menuConfig = [{text: 'Show Details', handler: show_win_fn.createDelegate(this, [null])}]
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    menu.show(row);    
  },
  
  showRolesGroupContextMenu: function(grid, field, value, evt){
    evt.preventDefault(); 
    
    if(!this.can_edit){
      return;
    }
    
    var elem = evt.getTarget();
    this.role_controller.siteId = value;
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items:[{
        text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditRoles({
            scenarioId: this.scenarioId,
            siteId: value,
            listeners: {
              scope: this,
              'save': function(win, u, r){
                win.showMask();
                this.role_controller.save(win, u, r);
              }
            }
          });
          win.show();
        }
      }]
    });
    
    menu.show(elem);
  },
  
  showQualsContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
        
    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
    
    if(!this.can_edit || record.get('status') === 'new'){
      return;
    }
    
    var qual_controller = new Talho.VMS.ux.QualificationController({scenarioId: this.scenarioId, siteId: record.get('site_id'), grid: grid});
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items:[{
        text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditQualification({
            creatingRecord: record,
            scenarioId: this.scenarioId,
            siteId: record.get('site_id'),
            listeners: {
              scope: qual_controller,
              'save': qual_controller.edit
            }
          });
          win.show();
        }
      },{
        text: 'Remove', handler: function(){
          Ext.Msg.confirm("Confirm Removal", "Are you sure you would like to remove this qualification requirement from the role/site?", function(btn){
            if(btn === 'yes'){
              qual_controller.remove(record);
            }
          });
        }
      }]
    });
    
    menu.show(row);
  },
  
  showTeamContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
    
    if(record.get('status') == 'new')
      return;
    
    if(this.can_edit){  
      var team_controller = new Talho.VMS.ux.TeamController({scenarioId: this.scenarioId, siteId: record.get('site_id'), grid: grid});
      
      menuConfig = [{
        text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditTeam({
            mode: 'edit',
            scenarioId: this.scenarioId,
            siteId: record.get('site_id'),
            creatingRecord: record,
            listeners: {
              scope: team_controller,
              'save': team_controller.edit
            }
          });
          
          win.show();
        }
      },{
        text: 'Remove', scope: this, handler: function(){
          Ext.Msg.confirm("Remove Team", "Are you sure you want to remove this team from the site? This action cannot be undone", function(btn){
            if(btn == 'yes'){
              team_controller.remove(record.id);
            }
          });
        }
      }];
    }
    else{
      menuConfig = [{text: 'Show Team Details', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditTeam({
            mode: 'show',
            scenarioId: this.scenarioId,
            siteId: record.get('site_id'),
            creatingRecord: record
          });
          
          win.show();
        }
      }]
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlighn: 'tr-br?',
      items: menuConfig
    });
      
    menu.show(row);
  },
  
  showStaffContextMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index),
        record = grid.getStore().getAt(row_index),
        menuConfig = [];
    
    if(record.get('status') == 'new')
      return;
    
    if(this.can_edit){
      this.staff_controller.siteId = record.get('site_id');
      menuConfig = [{
        text: 'Edit', scope: this, handler: function(){
            var win = new Talho.VMS.ux.CreateAndEditStaff({
              scenarioId: this.scenarioId,
              scenario_staff_store: this.staffGrid.getStore(),
              siteId: record.get('site_id'),
              listeners: {
                scope: this,
                'save': function(win, add, del){
                  win.showMask();
                  this.staff_controller.save(win, add, del);
                }
              }
            });
            win.show();
          }
        },
        {
          text: 'Remove', scope: this, handler: function(){
            Ext.Msg.confirm("Remove User", "Are you sure you wish to unassign this user from this site?", function(btn){
              if(btn === "yes"){
                this.staffGrid.loadMask.show();
                this.staff_controller.remove(record);
              }
            }, this);
          }
        }
      ];
    }
    else{
      menuConfig = [{
        text: 'Staff Details', scope: this, handler: function(){
            var win = new Talho.VMS.ux.CreateAndEditStaff({
              scenarioId: this.scenarioId,
              scenario_staff_store: this.staffGrid.getStore(),
              siteId: record.get('site_id'),
              readOnly: true
            });
            win.show();
          }
        }
      ]
    }
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig 
    });
    
    menu.show(row);
  },
  
  showStaffGroupContextMenu: function(grid, field, value, evt){
    evt.preventDefault();
    var elem = evt.getTarget();
    
    if(!this.can_edit){
      return;
    }
    
    this.staff_controller.siteId = value;
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items:[{
        text: 'Edit', scope: this, handler: function(){
          var win = new Talho.VMS.ux.CreateAndEditStaff({
            scenarioId: this.scenarioId,
            scenario_staff_store: this.staffGrid.getStore(),
            siteId: value,
            listeners: {
              scope: this,
              'save': function(win, add, del){
                win.showMask();
                this.staff_controller.save(win, add, del);
              }
            }
          });          
          win.show();
        }
      }]
    });
    
    menu.show(elem);
  }
};
