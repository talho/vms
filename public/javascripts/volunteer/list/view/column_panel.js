Ext.ns('Talho.VMS.Volunteer.List.View')

Talho.VMS.Volunteer.List.View.ColumnPanel = Ext.extend(Talho.VMS.ux.ColumnPanel, {
  initComponent: function(){
    this.items = [{xtype:'box', flex: .5},{xtype:'box', flex: 1}, {xtype: 'box', flex: 1}];
    Talho.VMS.ux.ColumnPanel.superclass.initComponent.apply(this, arguments); // Skip over the direct superclass (Talho.VMS.ux.ColumnPanel)
  },
  _setColumnX:function(x, cpt){
    cpt.flex = x === 0 ? .5 : 1;
    if(!this.getComponent(x))
      return;
    this.remove(this.getComponent(x));
    this.insert(x, cpt);
    this.doLayout();
  }
});