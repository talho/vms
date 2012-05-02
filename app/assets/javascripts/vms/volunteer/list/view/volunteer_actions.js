Ext.ns('Talho.VMS.Volunteer.List.View');

Talho.VMS.Volunteer.List.View.VolunteerActions = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('volunteer_qualifications_click', 'edit_volunteer_click');
    
    this.items = [
      {xtype: 'panel', margins: '5', region: 'center', layout: 'anchor', items: [
        {xtype: 'actionbutton', margins: '5', anchor: '100%', text: 'Edit Volunteer (new tab)', scope: this, handler: function(){this.fireEvent('edit_volunteer_click', this.record);}, iconCls: 'vms-list-edit-user'},
        {xtype: 'actionbutton', margins: '5', anchor: '100%', text: 'View/Modify Volunteer Qualifications', scope: this, handler: this.volunteerQualifications_click, iconCls: 'vms-list-qualifications'}
      ]}
    ];
    
    Talho.VMS.Volunteer.List.View.VolunteerActions.superclass.initComponent.apply(this, arguments);
  },
  
  volunteerQualifications_click: function(){
    this.fireEvent('volunteer_qualifications_click', this.record);
  }
});
