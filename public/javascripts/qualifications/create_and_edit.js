/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.CreateAndEditQualification = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  layout: 'form',
  initComponent: function(){
    this.items = [
      {xtype: 'combo', fieldLabel: 'Qualification', item_id: 'qual_selection', anchor: '100%', mode: 'local', store: new Ext.data.JsonStore({
        fields: ['name'],
        url: '/vms/qualifications.json',
        autoLoad: true,
        restful: true
      }), displayField: 'name', triggerAction: 'query', minChars: 0},
      {xtype: 'radio', item_id: 'radio_site', hideLabel: true, boxLabel: 'Apply Qualification to the Site', name: 'target', inputValue: 'site', checked: true},
      {xtype: 'radio', item_id: 'radio_role', hideLabel: true, boxLabel: 'Apply Qualification to this Role:', name: 'target', inputValue: 'role'},
      {xtype: 'combo', fieldLabel: 'Role', item_id: 'role_selection', anchor: '100%', mode: 'remote', triggerAction: 'all', minChars: 0, editable: false, store: new Ext.data.JsonStore({
        fields: ['role', 'id'],
        url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/roles.json',
        restful: true
      }), displayField: 'role', valueField: 'id', disabled: true}
    ],
    
    Talho.VMS.ux.CreateAndEditQualification.superclass.initComponent.apply(this, arguments);
    
    this.qualSelection = this.getComponent('qual_selection');
  }
});
