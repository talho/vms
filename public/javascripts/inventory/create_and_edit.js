Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.InventoryWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {  
  modal: true,
  
  constructor: function(config){
    this.mode = config.mode || (config.record && config.record.get('status') !== 'new' ? 'copy' : 'create');
    
    var name_config = {xtype: 'textfield', itemId: 'name', fieldLabel: 'Inventory/POD name', anchor: '100%'}
    if(this.mode === 'create') {
      Ext.apply(name_config, {xtype: 'combo', itemId: 'name', fieldLabel: 'Inventory/POD name', store: new Talho.VMS.ux.InventoryController.inventory_template_store({scenarioId: config.scenarioId}), displayField: 'name', valueField: 'id', queryParam: 'name',
        mode: 'remote', triggerAction: 'query', minChars: 0, listeners: {
        scope: this,
        'select': this.templateSelected
      }});
    }
    
    Ext.apply(config, {
      items: [
        name_config,
        {xtype: 'combo', itemId: 'source', fieldLabel: 'Source', displayField: 'name', queryParam: 'name', mode: 'remote', triggerAction: 'query', minChars: 0, store: new Ext.data.JsonStore({
        	url: '/vms/inventory_sources',
        	restful: true,
        	fields: ['name', 'id']
        })},
        {xtype:'radiogroup', itemId: 'type', hideLabel: true, items: [{boxLabel: 'Inventory', checked: true, inputValue: 'inventory', name: 'inventory_type'}, {boxLabel: 'POD', inputValue: 'pod', name: 'inventory_type'}]},
        {xtype: 'grid', itemId: 'items', anchor: '100%', height: 150, hideLabel: true, tbar: ['Items', '->', {text: 'Add Item', scope: this, handler: function(){this.showItemDetailWindow();} }], store: new Ext.data.JsonStore({
            fields: ['name', {name: 'quantity', type: 'int'}, 'category', 'consumable']
          }),
          columns: [
            {header: 'Name', dataIndex: 'name', id: 'name_column'},
            {header: 'Quantity', dataIndex: 'quantity', width: 60},
            {xtype: 'xactioncolumn', items: [
              {icon: '/stylesheets/vms/images/list-remove-2.png', handler: this.decrementQuantity, scope: this},
              {icon: '/stylesheets/vms/images/list-add-2.png', handler: this.incrementQuantity, scope: this}
            ]}
          ],
          autoExpandColumn: 'name_column',
          listeners:{
            scope: this,
            'rowcontextmenu': this.showItemMenu
          }
        },
        {xtype: 'checkbox', boxLabel: 'Save as a Template', itemId: 'template', checked: false, name: 'inventory_template', hideLabel: true}
    ]});
    
    Talho.VMS.ux.InventoryWindow.superclass.constructor.call(this, config);
  },
  
  initComponent: function(){
    Talho.VMS.ux.InventoryWindow.superclass.initComponent.apply(this, arguments);
    
    this.itemGrid = this.getComponent('items');
    
    if(this.mode !== 'create' && !Ext.isEmpty(this.record)){       
      this.on('afterrender', function(){this.loadMask = new Ext.LoadMask(this.getLayoutTarget()); this.loadMask.show();}, this, {delay: 1});
      Ext.Ajax.request({
        url: '/vms/scenarios/' + this.scenarioId + '/inventories/' + this.record.get('id') + (this.mode === 'edit' ? '/edit.json' : '.json'),
        method: 'GET',
        scope: this,
        success: this.loadComplete
      });
    }
  },
  
  loadComplete: function(result){
    var inv = Ext.decode(result.responseText);
    this.fillValues(inv);
    this.loadMask.hide();
  },
  
  templateSelected: function(combo, record, index){
    // mask the window
    if(!this.loadMask){
      this.loadMask = new Ext.LoadMask(this.getLayoutTarget());
    }
    this.loadMask.show();
    
    // load the data for the template
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/inventories/' + record.id + '.json',
      method: 'GET',
      scope: this,
      success: this.loadComplete
    });
  },
  
  fillValues: function(result){
    this.getComponent('name').setValue(this.mode === 'copy' ? ('Copy of ' + result.name ) : result.name );
    this.getComponent('source').setValue(result.source ? result.source.name : '');
    this.getComponent('type').items.get(0).setValue(!result.pod);
    this.getComponent('type').items.get(1).setValue(result.pod); // figure out how to get it from the radiogroup
    
    // Fill items
    this.getComponent('items').getStore().loadData(result.items);
  },
  
  onSaveClicked: function(){
    this.fireEvent('save', this, { name: this.getComponent('name').getValue(), 
      type: this.getComponent('type').getValue().getRawValue(), 
      items: this.itemGrid.getStore().getRange(), 
      template: this.getComponent('template').getValue(),
      source: this.getComponent('source').getValue()
    });
  },
  
  showItemDetailWindow: function(record){
    var mode = Ext.isObject(record) ? 'edit' : 'create';
    
    var win = new Ext.Window({
      height: 300,
      width: 300,
      title: 'Add Item',
      layout: 'fit',
      items: {
        xtype: 'form',
        itemId: 'form',
        items: [{xtype: 'textfield', fieldLabel: 'Item Name', name: 'name', value: mode === 'edit' ? record.get('name') : ''},
          {xtype: 'textfield', fieldLabel: 'Category', name: 'category', value: mode === 'edit' ? record.get('category') : ''},
          {xtype: 'textfield', fieldLabel: 'Quantity', name: 'quantity', value: mode === 'edit' ? record.get('quantity') : '', maskRe: /^\d*$/, filterKeys : function(e){
        if(e.ctrlKey){
            return;
        }
        var k = e.getKey();
        if(Ext.isGecko && (e.isNavKeyPress() || k == e.BACKSPACE || (k == e.DELETE && e.button == -1))){
            return;
        }
        var cc = String.fromCharCode(e.getCharCode());
        if(!Ext.isGecko && e.isSpecialKey() && !cc){
            return;
        }
        if(!this.maskRe.test(cc)){
            e.stopEvent();
        }
    }},
          {xtype: 'checkbox', hideLabel: true, boxLabel: 'Consumable', checked: false, inputValue: true, name: 'consumable', value: mode === 'edit' ? record.get('consumable') : ''}
        ]
      },
      buttons: [
        {text: mode === 'edit' ? 'Save' : 'Add', scope: this, handler: function(){
          var form = win.getComponent('form').getForm();
          var vals = form.getFieldValues();
          if(mode === 'edit'){
            record.set('name', vals['name']);
            record.set('category', vals['category']);
            record.set('quantity', vals['quantity']);
            record.set('consumable', vals['consumable']);
            record.commit();
          }
          else{
            this.itemGrid.getStore().add([new (this.itemGrid.getStore().recordType)(vals)]);
          }
          win.close();
        }},
        {text: 'Cancel', handler: function(){win.close();}}
      ]
    });
    
    win.show();
  },
  
  showItemMenu: function(grid, row_index, evt){
    evt.preventDefault();
    
    var row = grid.getView().getRow(row_index);
    var record = grid.getStore().getAt(row_index);
    
    var menuConfig = [
      {text: 'Edit', scope: this, handler: function(){
        this.showItemDetailWindow(record);
      }},
      {text: 'Remove', scope: this, handler: function(){
        grid.getStore().remove(record);
      }}
    ];
    
    var menu = new Ext.menu.Menu({
      floating: true, defaultAlign: 'tr-br?',
      items: menuConfig
    });
    
    menu.show(row);
  },
  
  incrementQuantity: function(grid, row){
    row = grid.getStore().getAt(row);
    row.set('quantity', row.get('quantity') + 1);
    grid.getStore().commitChanges();
  },
  
  decrementQuantity: function(grid, row){
    row = grid.getStore().getAt(row);
    if(row.get('quantity') > 0)
      row.set('quantity', row.get('quantity') - 1);
    grid.getStore().commitChanges();
  }
});