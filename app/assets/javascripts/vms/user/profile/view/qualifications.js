

Ext.ns("Talho.VMS.User.Profile.View");

Talho.VMS.User.Profile.View.Qualifications = Ext.extend(Ext.Panel, {
  layout: 'border',
  initComponent: function(){
    this.addEvents('qual_selected', 'qual_removed')
    var base_params = {};
    if(this.record) base_params['user_id'] = this.record.get('id');
    
    this.items = [
      {xtype: 'box', html: '<h1 style="text-align:center;">Qualifications</h1>', region: 'north', margins: '5'},
      {xtype: 'container', region: 'south', itemId: 'south_container', layout: 'form', margins: '5', labelAlign: 'top', items:[
        {xtype: 'container', fieldLabel: 'Add New Qualification', itemId: 'horz_container', layout: 'hbox', anchor: '100%', items: [
          {xtype: 'combo', itemId: 'qual_combo', displayField: 'name', triggerAction: 'query', name: 'VmsQualificationCombo', minChars: 0, autoSelect: false, typeAhead: true, store: new Ext.data.JsonStore({ fields: ['name'],
            url: '/vms/qualifications.json', autoLoad: true, restful: true }), flex: 1,
            listeners: {
              scope: this,
              'select': this._qual_selected,
              'specialkey': function(field, e){
                if(e.getKey() == e.ENTER && !Ext.isEmpty(this.qual_combo.getValue()))
                  this._qual_selected();
              }
            }},
          {xtype: 'button', text: 'Add', margins: '0 0 0 5', scope: this, handler: this._qual_selected }
        ]}
      ]},
      {xtype: 'grid', cls: 'vms-qualification-grid', margins: '5', region: 'center', itemId: 'qual_grid', sm: Ext.grid.AbstractSelectionModel(), store: new Ext.data.JsonStore({fields: Talho.VMS.Model.Qualification,
          idProperty: 'id', url: '/vms/user_qualifications.json', autoLoad: true, autoSave: false, restful: true, baseParams: base_params,
          listeners: {
            scope: this,
            'beforesave': function(){
              if(!this.qual_grid.saveMask) this.qual_grid.saveMask = new Ext.LoadMask(this.qual_grid.getEl(), {msg: 'Saving...'});
              this.qual_grid.saveMask.show();
            },
            'save': function(){
              this.qual_grid.saveMask.hide();
            }
          },
          writer: new Ext.data.JsonWriter({render : function(params, baseParams, data) {
              Ext.apply(params, baseParams);
              Ext.apply(params, data);
            }
          })
        }),
        hideHeaders: true, columns: [
          {id: 'name_column', dataIndex: 'name'},
          {xtype: 'xactioncolumn', icon: '/assets/vms/action_delete.png', iconCls: 'remove_qual', handler: this._removeQual_click, scope: this}
        ],
        autoExpandColumn: 'name_column', loadMask: true
      }
    ];
    
    Talho.VMS.User.Profile.View.Qualifications.superclass.initComponent.apply(this, arguments);
    
    this.qual_grid = this.getComponent('qual_grid');
    this.qual_combo = this.getComponent('south_container').getComponent('horz_container').getComponent('qual_combo');
  },
  
  _qual_selected: function(){
    this.fireEvent('qual_selected', this.qual_combo.getValue());
  },
  
  _removeQual_click: function(grid, row){
    var r = grid.getStore().getAt(row);
    this.fireEvent('qual_removed', r);
  },
  
  clearQualificationCombo: function(){
    this.qual_combo.clearValue();
  }
});
