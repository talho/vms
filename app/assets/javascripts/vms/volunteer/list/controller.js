//= require vms/extensions/column_panel
//= require vms/model/volunteer
//= require vms/extensions/action_button
//= require_tree ./view
//= require vms/user/profile/view/qualifications

Ext.ns('Talho.VMS.Volunteer.List')

Talho.VMS.Volunteer.List.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    
    this.columnPanel = new Talho.VMS.Volunteer.List.View.ColumnPanel({
      title: 'Volunteer List'
    });
    
    this.columnPanel.setColumn1(new Talho.VMS.Volunteer.List.View.ListActions({
      listeners: {
        scope: this,
        'list_click': this.showVolunteerList,
        'status_check_click': this.showStatusChecks,
        'alert_click': this.showAlertPanes
      }
    }))
    
    this.columnPanel.on('afterrender', function(){this.showVolunteerList();}, this, {delay: 1, once: true});
    Talho.VMS.Volunteer.List.Controller.superclass.constructor.apply(this, arguments);
  },
  
  showVolunteerList: function(){
    var actions = this.columnPanel.getColumn1();
    if(actions.getCurrentAction() == 'Volunteer List')
      return;
    actions.setAction('Volunteer List');
    
    this.columnPanel.setColumn2(new Talho.VMS.Volunteer.List.View.List({
      listeners: {
        scope: this,
        'volunteer_select': this.volunteer_select
      }
    }));
    this.columnPanel.setColumn3({xtype: 'box'});
  },
  
  showStatusChecks: function(){
    var actions = this.columnPanel.getColumn1();
    if(actions.getCurrentAction() == 'Status Checks')
      return;
    actions.setAction('Status Checks');
    
    this.columnPanel.setColumn2(new Talho.VMS.Volunteer.List.View.StatusChecks({
      listeners: {
        scope: this,
        'status_check_select': this.showStatusResponders,
        'new_status_check': this.showNewStatusCheck
      }
    }));
    this.columnPanel.setColumn3({xtype: 'box'});
  },
  
  showAlertPanes: function(){
    var actions = this.columnPanel.getColumn1();
    if(actions.getCurrentAction() == 'Alert')
      return;
    actions.setAction('Alert');
      
    this.columnPanel.setColumn2(new Talho.VMS.Volunteer.List.View.List({
      chooseMode: true
    }));
    this.columnPanel.setColumn3(new Talho.VMS.Volunteer.List.View.Alert({
      listeners: {
        scope: this,
        'send_alert': this.sendAlert
      }
    }));
  },
  
  volunteer_select: function(vol){
    this.columnPanel.setColumn3(new Talho.VMS.Volunteer.List.View.VolunteerActions({
      record: vol,
      listeners: {
        scope: this,
        'volunteer_qualifications_click': this.showVolunteerQualifications,
        'edit_volunteer_click': this.launchEditUserTab
      }
    }));
  },
  
  showVolunteerQualifications: function(vol){
    this.columnPanel.setColumn3(new Talho.VMS.User.Profile.View.Qualifications({record: vol,
      listeners: {
        scope: this,
        'qual_removed': this.qualification_removed,
        'qual_selected': this.qualification_added
      },
      buttons: [{text: 'Back', handler: this.volunteer_select.createDelegate(this, [vol])}]
    }))
  },
  
  showStatusResponders: function(sc){
    this.columnPanel.setColumn3(new Talho.VMS.Volunteer.List.View.StatusResponders({
      record: sc
    }));
  },
  
  showNewStatusCheck: function(){
    this.columnPanel.setColumn3(new Talho.VMS.Volunteer.List.View.NewStatusCheck({
      listeners: {
        scope: this,
        'cancel': this.cancelNewStatusCheck,
        'submit_new_status_check': this.submitStatusCheck
      }
    }));
  },
  
  cancelNewStatusCheck: function(){
    var nsc = this.columnPanel.getColumn3();
    this.columnPanel.setColumn3({xtype: 'box'});
    nsc.destroy();
  },
  
  qualification_removed: function(r){
    var store = this.columnPanel.getColumn3().qual_grid.getStore();
    store.remove(r);
    store.save();
  },
  
  qualification_added: function(qual){
    var store = this.columnPanel.getColumn3().qual_grid.getStore();
    // check for duplicates
    if(store.find('name', new RegExp('^' + qual + '$')) !== -1){
      this.columnPanel.getColumn3().clearQualificationCombo();
      return;
    }
    
    store.add(new Talho.VMS.Model.Qualification({name: qual}));
    store.save();
    this.columnPanel.getColumn3().clearQualificationCombo();
  },
  
  launchEditUserTab: function(vol){
    Application.fireEvent('opentab', {
      title: 'Edit Account: ' + vol.get('name'),
      url: '/users/' + vol.get('id') + '/profile',
      user_id: vol.get('id'),
      id: 'edit_user_for_' + vol.get('id'), 
      initializer: 'Talho.EditProfile'
    });
  },
  
  sendAlert: function(title, message){
    var vols = this.columnPanel.getColumn2().getSelectedVolunteers();
    var vol_ids = [];
    Ext.each(vols, function(vol){vol_ids.push(vol.get('id'))});
    this.showSavingMask();
    Ext.Ajax.request({
      url: '/vms/alerts',
      method: 'POST',
      params: {
        title: title,
        message: message,
        'user_ids[]': vol_ids
      },
      scope: this,
      success: function(){
        this.hideSavingMask();
        this.showVolunteerList();
      },
      failure: function(){
        Ext.Msg.alert('There was an error sending the alert. Please try again.');
        this.hideSavingMask();
      }
    });
  },
  
  submitStatusCheck: function(vols, message){
    var vol_ids = [];
    Ext.each(vols, function(vol){vol_ids.push(vol.get('id'))});
    this.showSavingMask();
    Ext.Ajax.request({
      url: '/vms/alerts',
      method: 'POST',
      params: {
        alert_type: 'VmsStatusCheckAlert',
        message: message,
        'user_ids[]': vol_ids
      },
      scope: this,
      success: function(){
        this.columnPanel.getColumn2().reloadStatusChecks();
        this.columnPanel.setColumn3({xtype: 'box'});
        this.hideSavingMask();
      },
      failure: function(){
        Ext.Msg.alert('There was an error creating the new status check. Please try again.');
        this.hideSavingMask();
      }
    });
  },
  
  showSavingMask: function(){
    if(!this.columnPanel.saveMask) this.columnPanel.saveMask = new Ext.LoadMask(this.columnPanel.getEl(), {msg: 'Saving...'});
    this.columnPanel.saveMask.show();
  },
  
  hideSavingMask: function(){
    if(this.columnPanel.saveMask) this.columnPanel.saveMask.hide();
  }
});

Talho.ScriptManager.reg('Talho.VMS.Volunteer.List', Talho.VMS.Volunteer.List.Controller, function(config){
  var ctrl = new Talho.VMS.Volunteer.List.Controller(config);
  return ctrl.columnPanel;
});