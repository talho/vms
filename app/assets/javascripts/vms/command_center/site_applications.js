/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux.CommandCenter');

Talho.VMS.ux.CommandCenter.SiteApplications = {  
  addInventoryToSite: function(record, site){
    var inv_win_fn = function(){        
      var win = new Talho.VMS.ux.InventoryWindow({
        scenarioId: this.scenarioId,
        record: record,
        listeners: {
          scope: this,
          'save': function(win, values){
            win.showMask();
            this.inventory_controller.create(win, values, record, this.scenarioId, site);
           } 
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
            this.inventoryGrid.loadMask.show();
            this.inventory_controller.move(record, this.scenarioId, site);
          }
          else if(btn === 'no'){
            inv_win_fn();
          }
        }        
      });
    }
  },
  
  addRoleToSite: function(record, site){ 
    this.role_controller.siteId = site.id; 
    var win_cfg = {
      scenarioId: this.scenarioId,
      siteId: site.id,
      listeners: {
        scope: this,
        'save': function(win, u, r){
          win.showMask();
          this.role_controller.save(win, u, r);
        }
      }
    };
    if(site.id != record.get('site_id') ) win_cfg['creatingRecord'] = record;
    var win = new Talho.VMS.ux.CreateAndEditRoles(win_cfg);
    win.show();
  },
  
  copyRolesToSite: function(source_site_id, destination_record){
    // Go get the roles for the source site
    // launch the create and edit role window with those roles pre-set (or added)
    this.role_controller.siteId = destination_record.id;
    var role_store = this.rolesGrid.getStore();
    var roles = role_store.query('site_id', new RegExp('^' + source_site_id + '$'));
    var win = new Talho.VMS.ux.CreateAndEditRoles({
      seededRolesCollection: roles,
      scenarioId: this.scenarioId,
      siteId: destination_record.id,
      listeners: {
        scope: this,
        'save': function(win, u, r){
          win.showMask();
          this.role_controller.save(win, u, r);
        }
      }
    });
    win.show();
  },
  
  /*
   * Add team to the site. Determine if the dragged record is the 'new' record or an existing one. If it's new, show the window. If it's existing,
   * confirm reassignment of team.
   * @param {Ext.data.Record} record  The record that was dragged to the site
   * @param {Ext.data.Record} site    The site that was dragged onto
   */
  addTeamToSite: function(record, site){
    var controller = new Talho.VMS.ux.TeamController({scenarioId: this.scenarioId, siteId: site.id, grid: this.teamsGrid});
    if(record.get('status') === 'new'){
      var win = new Talho.VMS.ux.CreateAndEditTeam({
        record: record,
        listeners: {
          scope: controller,
          'save': controller.save
        }
      });
      win.show();
    }
    else if(record.get('site_id') !== site.id){
      Ext.Msg.confirm("Move Team", "Performing this action will reassign the " + record.get('name') + " team to the " + site.get('name') + " site.", function(btn){
        if(btn === 'yes'){
          controller.move(record, site);
        }
      }, this);
    }
  },
  
  addUserToSite: function(record, site){
    this.staff_controller.siteId = site.id;
    if(record.get('status') === 'new' || record.get('site_id') == site.id){
      var win = new Talho.VMS.ux.CreateAndEditStaff({
        creatingRecord: record,
        scenarioId: this.scenarioId,
        scenario_staff_store: this.staffGrid.getStore(),
        siteId: site.id,
        listeners:{
          scope: this,
          'save': function(win, add, del){
            win.showMask();
            this.staff_controller.save(win, add, del);
          }
        }
      });
      win.show();
    }
    else{
      this.staffGrid.loadMask.show();
      this.staff_controller.move(record);
    }
  },
  
  addQualificationToSite: function(record, site){
    var controller = new Talho.VMS.ux.QualificationController({scenarioId: this.scenarioId, siteId: site.id, grid: this.qualsGrid});
    var save_fn = controller.create;
    if(site.id === record.get('site_id')) save_fn = controller.edit;
    
    var win = new Talho.VMS.ux.CreateAndEditQualification({
      creatingRecord: record,
      scenarioId: this.scenarioId,
      siteId: site.id,
      grid: this.qualsGrid,
      listeners: {
        scope: controller,
        'save': save_fn
      }
    });
    win.show();
  }
};
