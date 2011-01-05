Ext.ns("Talho.VMS")

Talho.VMS.CommandCenter = Ext.extend(Ext.Panel, {
  title: 'VMS Command Center',
  closable: true,
  layout: 'border',
  
  constructor: function(){
    this.items = [{region: 'center', html: 'Map Goes Here', padding: '5'},
      { xtype: 'container', region: 'west', layout: 'accordion', items:[
        { title: 'Site', xtype: 'grid', hideHeaders: true, enableDragDrop: true,
          store: new Ext.data.JsonStore({ fields: ['name'], data: [{name: 'FBC'}, {name: 'Immunization Center'}]}),
          columns: [
            {xtype: 'templatecolumn', id: 'name_column', tpl: '<div class="vms-row-icon"></div><div class="vms-row-text">{name}</div><div style="clear:both;"></div>'}
          ],
          autoExpandColumn: 'name_column', buttonAlign: 'right', buttons: [{text: 'Add/Create Site'}]},
        {title: 'PODS/Inventory', buttons: [{text: 'Add/Create Inventory'}]}
      ], width: 200, split: true },
      { xtype: 'container', region: 'east', layout: 'accordion', items:[
        {title: 'Exigency Profile', html: 'This will contain a profile of sites, roles, teams, and staff'},
        {title: 'Roles', html: 'This will show common roles as availible and activated roles as assigned', fbar: { layout: 'anchor', items: [{xtype: 'combo', anchor: '100%', store: ['role'], editable: false}] } },
        {title: 'Teams', html: 'This will show common teams as availible and activated teams as assigned', buttons: [{text: 'Add/Create Team'}]},
        {title: 'Staff', html: 'This will show all people added through teams and roles with different statuses: if they are individually availible/assigned, if they are assigned by team/role, and common, unassigned people',
          fbar: { layout: 'anchor', items: [{xtype: 'combo', store:['user'], anchor: '100%'}]}
        }
      ], width: 200, split: true }
    ];
    
    Talho.VMS.CommandCenter.superclass.constructor.apply(this, arguments);
  }
});

Talho.ScriptManager.reg('Talho.VMS.CommandCenter', Talho.VMS.CommandCenter, function(){return new Talho.VMS.CommandCenter();});
