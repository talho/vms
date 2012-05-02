Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.InventoryWindow = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {  
  modal: true,
  padding: '5',
  autoHeight: true,
  cls: 'inventoryWindow',
  initComponent: function(){
    this.mode = this.mode || (this.record && this.record.get('status') !== 'new' ? 'copy' : 'create');
    
    this.setTitle(this.getTitle());
    
    var name_config = {xtype: 'textfield', readOnly: this.mode === 'show', itemId: 'name', fieldLabel: 'Inventory/POD Name', anchor: '100%'}
    if(this.mode === 'create') {
      Ext.apply(name_config, {xtype: 'combo', store: new Talho.VMS.ux.InventoryController.inventory_template_store({scenarioId: this.scenarioId}), displayField: 'name', queryParam: 'name',
        mode: 'remote', triggerAction: 'query', minChars: 0, listeners: {
        scope: this,
        'select': this.templateSelected
      }});
    }
    
    var columns = [
      {header: 'Name', dataIndex: 'name', id: 'name_column'},
      {header: 'Quantity', dataIndex: 'quantity', width: 60}
    ];
    var grid_tbar = ['Items', '->', {text: 'Add Item', scope: this, handler: function(){this.showItemDetailWindow();} }];
    
    if(this.mode !== 'show'){
      columns.push({xtype: 'xactioncolumn', items: [
        {icon: '/assets/vms/list-remove-2.png', iconCls: 'decreaseItem', handler: this.decrementQuantity, scope: this},
        {icon: '/assets/vms/list-add-2.png', iconCls: 'increaseItem', handler: this.incrementQuantity, scope: this}
      ]});
    }
    else{
      grid_tbar = ['Items'];
    }
    
    this.items = [
      name_config,
      {xtype: 'combo', itemId: 'source', readOnly: this.mode === 'show', anchor: '100%', fieldLabel: 'Source', displayField: 'name', queryParam: 'name', mode: 'remote', triggerAction: 'query', minChars: 0, store: new Ext.data.JsonStore({
      	url: '/vms/inventory_sources',
      	restful: true,
      	fields: ['name', 'id']
      })},
      {xtype:'radiogroup', itemId: 'type', anchor: '100%', hideLabel: true, items: [{boxLabel: 'Inventory', readOnly: this.mode === 'show', checked: true, inputValue: 'inventory', name: 'inventory_type'}, {boxLabel: 'POD', readOnly: this.mode === 'show', inputValue: 'pod', name: 'inventory_type'}]},
      {xtype: 'grid', itemId: 'items', cls: 'itemGrid', anchor: '100%', height: 150, hideLabel: true, tbar: grid_tbar, store: new Ext.data.JsonStore({
          fields: ['name', {name: 'quantity', type: 'int'}, 'category', 'consumable']
        }),
        columns: columns,
        autoExpandColumn: 'name_column',
        listeners:{
          scope: this,
          'rowcontextmenu': this.mode === 'show' ? Ext.emptyFn : this.showItemMenu
        }
      },
      {xtype: 'checkbox', boxLabel: 'Save as a Template', readOnly: this.mode === 'show', anchor: '100%', itemId: 'template', checked: false, name: 'inventory_template', hideLabel: true}
    ]
    
    if(this.mode === 'show'){
      this.buttons = [{text: 'Close', scope: this, handler: function(){this.close();}}]
    }
    
    Talho.VMS.ux.InventoryWindow.superclass.initComponent.apply(this, arguments);
    
    this.itemGrid = this.getComponent('items');
    
    if(this.mode !== 'create' && (!Ext.isEmpty(this.record) || !Ext.isEmpty(this.inventoryId))){
      var id = !Ext.isEmpty(this.record) ? this.record.get('id') : this.inventoryId;
      this.on('afterrender', function(){this.loadMask = new Ext.LoadMask(this.getLayoutTarget()); this.loadMask.show();}, this, {delay: 1});
      Ext.Ajax.request({
        url: '/vms/scenarios/' + this.scenarioId + '/inventories/' + id + (this.mode === 'edit' ? '/edit.json' : '.json'),
        method: 'GET',
        scope: this,
        success: this.loadComplete
      });
    }
  },
  
  getTitle: function(){
    switch(this.mode){
      case 'edit': return 'Edit POD/Inventory';
      case 'copy': return 'Copy POD/Inventory';
      case 'show': return 'View POD/Inventory';
      default: return 'Create POD/Inventory';
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
      height: 200,
      width: 350,
      modal: true,
      title: mode === 'edit' ? 'Change Item' : 'Add Item',
      cls: 'addItemWindow',
      layout: 'fit',
      items: {
        padding: '5',
        xtype: 'form',
        itemId: 'form',
        items: [{xtype: 'combo', fieldLabel: 'Item Name', name: 'name', value: mode === 'edit' ? record.get('name') : '', anchor: '100%', displayField: 'name', queryParam: 'name', mode: 'remote', triggerAction: 'query', minChars: 0, store: new Ext.data.JsonStore({
            url: '/vms/inventory_items',
            restful: true,
            fields: ['name', 'id', {name: 'item_category', convert: function(val){ if(Ext.isObject(val)) return val['name']; else return val; } }, {name: 'consumable', type: 'boolean'}]
          }),
          listeners: {
            scope: this,
            'select': function(combo, record){
              // apply the data to the window
              win.getComponent('form').getComponent('category').setValue(record.get('item_category'));
              win.getComponent('form').getComponent('consumable').setValue(record.get('consumable'));
            }
          }},
          {xtype: 'combo', fieldLabel: 'Category', itemId: 'category', name: 'category', value: mode === 'edit' ? record.get('category') : '', anchor: '100%', displayField: 'name', queryParam: 'name', mode: 'remote', triggerAction: 'query', minChars: 0, store: new Ext.data.JsonStore({
            url: '/vms/inventory_item_categories',
            restful: true,
            fields: ['name', 'id']
          })},
          {xtype: 'textfield', fieldLabel: 'Quantity', name: 'quantity', value: mode === 'edit' ? record.get('quantity') : '', anchor: '100%', maskRe: /^\d*$/, filterKeys : function(e){
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
          {xtype: 'checkbox', itemId: 'consumable', hideLabel: true, boxLabel: 'Consumable', checked: false, inputValue: true, name: 'consumable', value: mode === 'edit' ? record.get('consumable') : ''}
        ]
      },
      buttons: [
        {text: mode === 'edit' ? 'Save' : 'Add', scope: this, handler: function(){
          var form = win.getComponent('form').getForm();
          var vals = form.getFieldValues();
          if(mode === 'edit'){
            record.set('name', vals['name']);
            record.set('category', vals['category']);
            record.set('quantity', vals['quantity']*1);
            record.set('consumable', vals['consumable']);
            record.commit();
          }
          else{
            var itemStore = this.itemGrid.getStore();
            var index = itemStore.find('name', new RegExp('^' + vals['name'] + '$'));
            if(index === -1) 
              itemStore.add([new (this.itemGrid.getStore().recordType)(vals)]);
            else {
              Ext.MessageBox.show({
                title: 'Attempting to Add Duplicate Item',
                msg: 'The item you have selected already exists for this inventory. What would you like to do?',
                buttons: {yes: 'Replace', no: 'Add to Existing', cancel: 'Cancel'},
                scope: this,
                fn: function(btnId){
                  if(btnId === 'yes'){
                    itemStore.removeAt(index);
                    itemStore.add([new (this.itemGrid.getStore().recordType)(vals)]);
                  }
                  else if(btnId === 'no'){
                    var orig = itemStore.getAt(index);
                    orig.set('quantity', orig.get('quantity')*1 + vals['quantity']*1); // make sure vals['quantity'] is added as an integer
                    orig.commit();
                  }
                }
              })
            }
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
    row.set('quantity', row.get('quantity')*1 + 1);
    grid.getStore().commitChanges();
  },
  
  decrementQuantity: function(grid, row){
    row = grid.getStore().getAt(row);
    if(row.get('quantity') > 0)
      row.set('quantity', row.get('quantity')*1 - 1);
    grid.getStore().commitChanges();
  }
});