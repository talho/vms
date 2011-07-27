
Ext.ns('Talho.VMS.User.Profile')

Talho.VMS.User.Profile.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function(config){
    Ext.apply(this, config);
    Talho.VMS.User.Profile.Controller.superclass.constructor.apply(this, arguments);
    
    this.columnPanel = new Talho.VMS.ux.ColumnPanel({
      title: config['title'] || 'My Volunteer Profile'
    });
    
    // set column 1 to the qualifications view
    this.columnPanel.setColumn1(new Talho.VMS.User.Profile.View.Qualifications({
      listeners: {
        scope: this,
        'qual_removed': this.qualification_removed,
        'qual_selected': this.qualification_added
      }
    }));
    
    // set column 2 to the alerts view
    this.columnPanel.setColumn2(new Talho.VMS.User.Profile.View.Alerts({
      listeners: {
        scope: this,
        'alert_selected': this.alert_selected
      }
    }));
  },
  
  qualification_removed: function(r){
    var store = this.columnPanel.getColumn1().qual_grid.getStore();
    store.remove(r);
    store.save();
  },
  
  qualification_added: function(qual){
    var store = this.columnPanel.getColumn1().qual_grid.getStore();
    // check for duplicates
    if(store.find('name', new RegExp('^' + qual + '$')) !== -1){
      this.columnPanel.getColumn1().clearQualificationCombo();
      return;
    }
    
    store.add(new Talho.VMS.Model.Qualification({name: qual}));
    store.save();
    this.columnPanel.getColumn1().clearQualificationCombo();
  },
  
  alert_selected: function(r){
    var c3 = this.columnPanel.getColumn3();
    
    this.columnPanel.setColumn3(new Talho.VMS.User.Profile.View.AlertDetail({
      record: r,
      listeners: {
        scope: this,
        'call_down_selected': this.callDown_selected
      }
    }));
    
    c3.purgeListeners();
    c3.destroy();
  },
  
  /**
   * User has selected a call down choice. Post to server this choice and communicate back to the view that we've made a choice
   * @params  val Integer The integer value of the calldown that the user selected
   */
  callDown_selected: function(alert, val){
    var detail = this.columnPanel.getColumn3();
    if(!detail.saveMask) detail.saveMask = new Ext.LoadMask(detail.getEl(), {msg: 'Saving...'});
    detail.saveMask.show();
    
    Ext.Ajax.request({
      method: 'POST',
      url: '/vms/alerts/' + alert.get('id') + '/acknowledge.json',
      params: {response: val},
      success: function(){
        alert.set('acknowledged_at', new Date());
        alert.set('call_down_response', val);
        detail.saveMask.hide();
        detail.setSelectedCallDown(val);
      }
    })
  }
});

Talho.ScriptManager.reg('Talho.VMS.User.Profile', Talho.VMS.User.Profile.Controller, function(config){
  var ctrl = new Talho.VMS.User.Profile.Controller(config);
  return ctrl.columnPanel;
});