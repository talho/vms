Ext.ns('Talho.VMS.ux')

Talho.VMS.ux.ColumnPanel = Ext.extend(Ext.Panel, {
  layout: 'hbox',
  closable: true,
  layoutConfig: {
    align: 'stretch',
    defaultMargins: '5'
  },
  initComponent: function(){
    this.items = [{xtype:'box', flex: 1},{xtype:'box', flex: 1}, {xtype: 'box', flex: 1}];
    Talho.VMS.ux.ColumnPanel.superclass.initComponent.apply(this, arguments);
  },
  getColumn1: function(){
    return this.getComponent(0);
  },
  getColumn2: function(){
    return this.getComponent(1);
  },
  getColumn3: function(){
    return this.getComponent(2);
  },
  setColumn1: function(cpt){
    this._setColumnX(0, cpt);
  },
  setColumn2: function(cpt){
    this._setColumnX(1, cpt);
  },
  setColumn3: function(cpt){
    this._setColumnX(2, cpt);
  },
  
  _setColumnX:function(x, cpt){
    cpt.flex = 1;
    if(!this.getComponent(x))
      return;
    this.remove(this.getComponent(x));
    this.insert(x, cpt);
    this.doLayout();
  }
});
