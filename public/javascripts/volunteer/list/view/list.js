Ext.ns('Talho.VMS.Volunteer.List.View')

Talho.VMS.Volunteer.List.View.List = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('volunteer_select');
    
    this.items = [
      {xtype: 'box', margins: '5', region: 'north', html: '<h1 style="text-align:center;">Volunteers</h1>'},
      {xtype: 'volunteerlist', margins: '5', region: 'center', itemId: 'vol_grid', chooseMode: this.chooseMode}
    ];
    
    Talho.VMS.Volunteer.List.View.List.superclass.initComponent.apply(this, arguments);
    
    this.grid = this.getComponent('vol_grid');
    this.grid.getSelectionModel().on('rowselect', this.row_select, this);
  },
  
  row_select: function(sm,index,r){
    this.fireEvent('volunteer_select', r);
  },
  
  getSelectedVolunteers: function(){
    return this.grid.getSelectionModel().getSelections();
  }
});
