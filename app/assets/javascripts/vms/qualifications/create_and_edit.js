/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.CreateAndEditQualification = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {
  layout: 'form',
  title: 'Add Qualification',
  initComponent: function(){
    this.items = [
      {xtype: 'combo', fieldLabel: 'Qualification', itemId: 'qual_selection', anchor: '100%', mode: 'local', store: new Ext.data.JsonStore({
        fields: ['name'],
        url: '/vms/qualifications.json',
        autoLoad: true,
        restful: true
      }), displayField: 'name', triggerAction: 'query', minChars: 0},
      {xtype: 'radio', itemId: 'radio_site', hideLabel: true, boxLabel: 'Apply Qualification to the Site', name: 'target', inputValue: 'site', checked: true},
      {xtype: 'radio', itemId: 'radio_role', hideLabel: true, boxLabel: 'Apply Qualification to this Role:', name: 'target', inputValue: 'role', listeners: {
        scope: this,
        'check': function(rb, checked){
          this.roleSelection.setDisabled(!checked);
        }
      }},
      {xtype: 'combo', fieldLabel: 'Apply to Role', lazyInit: false, itemId: 'role_selection', cls: 'qual-role-selection', anchor: '100%', mode:'local', triggerAction: 'all', minChars: 0, editable: false, store: new Ext.data.JsonStore({
        fields: ['role', 'role_id'],
        url: '/vms/scenarios/' + this.scenarioId + '/sites/' + this.siteId + '/roles.json',
        restful: true,
        autoLoad: true,
      }), displayField: 'role', valueField: 'role_id', disabled: true}
    ],
    
    Talho.VMS.ux.CreateAndEditQualification.superclass.initComponent.apply(this, arguments);
    
    this.qualSelection = this.getComponent('qual_selection');
    this.roleSelection = this.getComponent('role_selection');
    this.roleRadio = this.getComponent('radio_role');
    
    if(this.creatingRecord && this.creatingRecord.get('status') !== 'new'){
      if(this.creatingRecord.get('site_id') == this.siteId){
        this.setTitle('Modify Qualification');
      }
      else{
        this.setTitle('Copy Qualification');
      }
      
      this.qualSelection.setValue(this.creatingRecord.get('name'));
      var role_id = this.creatingRecord.get('role_id');
      if(role_id){
        this.on('afterrender', function(){
          this.showMask('Loading...');
        }, this, {delay:1});
        this.roleSelection.getStore().on('load', function(){
            this.hideMask();
            if(this.roleSelection.findRecord('role_id', role_id)){
              this.roleSelection.setValue(role_id);
            }
          }, this, {once: true});
        this.roleRadio.setValue(true);
      }
    } 
  },
  
  onSaveClicked: function(){
    tag = this.qualSelection.getValue();
    role = this.roleRadio.checked ? this.roleSelection.getValue() : null;
    this.fireEvent('save', this, tag, role);
  }
});
