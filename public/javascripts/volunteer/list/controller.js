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
    
    Talho.VMS.Volunteer.List.Controller.superclass.constructor.apply(this, config);
  },
  
  showVolunteerList: function(){
    this.columnPanel.setColumn2(new Talho.VMS.Volunteer.List.View.VolunteerList({
      
    }));
  },
  
  showStatusChecks: function(){
    
  },
  
  showAlertPanes: function(){
    
  }
});

Talho.ScriptManager.reg('Talho.VMS.Volunteer.List', Talho.VMS.Volunteer.List.Controller, function(config){
  var ctrl = new Talho.VMS.Volunteer.List.Controller(config);
  return ctrl.columnPanel;
});