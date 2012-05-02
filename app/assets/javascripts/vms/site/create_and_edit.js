/**
 * @author Charles DuBose
 */
Ext.ns('Talho.VMS.ux'); 

Talho.VMS.ux.CreateAndEditSite = Ext.extend(Talho.VMS.ux.ItemDetailWindow, {  
  initComponent: function(){
    var status = this.record.get('status');
    if (this.mode === undefined) this.mode = status === 'active' ? 'copy' : status === 'new' ? 'create' : 'activate';
    
    switch(this.mode){
      case 'copy': this.title = 'Copy Site';
        break;
      case 'edit': this.title = 'Edit Site';
        break;
      case 'create': this.title = 'Create Site';
        break;
      case 'activate': this.title = 'Activate Site';
        break;        
    }
    
    var name_field_config = {xtype: 'textfield', itemId: 'name_field', fieldLabel: 'Name', anchor: '100%', value: this.mode != 'create' ? (this.mode == 'copy' ? 'Copy of ' : '') + this.record.get('name') : '' };
    
    if(this.mode === 'create'){
      var json_store = new Ext.data.JsonStore({
        url: '/vms/scenarios/' + this.scenarioId + '/sites/existing',
        idProperty: 'id',
        root: 'sites',
        fields: ['name', 'lat', 'lng', 'id', 'address']
      });
      Ext.apply(name_field_config, {xtype: 'combo', queryParam: 'name',
        mode: 'remote', triggerAction: 'query', 
        store: json_store, displayField: 'name', valueField: 'name',
        tpl:'<tpl for="."><div ext:qtip=\'{address}\' class="x-combo-list-item">{name}</div></tpl>',
        minChars: 0,
        listeners: {
          scope: this,
          'select': this.applySiteTemplate
        }
      });
    }
    
    this.original_address = '';
    if(this.mode === 'edit'){
      this.original_address = this.record.get('address');
    }
    else if(this.mode === 'activate'){
      this.original_address = this.record.get('address');
      this.map.geocoder.geocode({address: this.original_address}, function(results, status){
        this.latLng = results[0].geometry.location;
      }.createDelegate(this));
    }
    else {
      this.map.geocoder.geocode({latLng: this.latLng}, function(results, status){
        this.original_address = results[0].formatted_address;
        this.getComponent('address_field').setValue(this.original_address);
      }.createDelegate(this));
    }
    
    this.items = [
      name_field_config,
      {xtype: 'textfield', itemId: 'address_field', fieldLabel: 'Address', anchor: '100%', value: this.original_address}
    ];
    
    Talho.VMS.ux.CreateAndEditSite.superclass.initComponent.apply(this, arguments);
  },
  
  applySiteTemplate: function(combo, r, index){
    this.mode = 'activate';
    this.record = new (this.recordType)({status: 'active', type: 'site'});
    this.record.id = r.get('id');
    this.record.set('id', r.get('id'));
    this.record.set('name', r.get('name'));
    this.record.set('address', r.get('address'));
    this.record.set('lat', r.get('lat'));
    this.record.set('lng', r.get('lng'));
    this.getComponent('address_field').setValue(r.get('address'));
  },
  
  onSaveClicked: function(){
    this.fireEvent('save', this, this.record);
  }
});
/*
var mode = 'activate';
    
    if(record.get('status') == 'new')
      mode = 'new';
    else if(record.get('status') == 'active')
      mode = 'copy';
    
    var original_address = '';
    if(mode == 'activate' && !Ext.isEmpty(record.get('address')) ){
      original_address = record.get('address');
      this.map.geocoder.geocode({address: original_address}, function(results, status){
        latLng = results[0].geometry.location;
      }.createDelegate(this));
    }
    else {
      this.map.geocoder.geocode({latLng: latLng}, function(results, status){
        original_address = results[0].formatted_address;
        win.getComponent('address_field').setValue(original_address);
      }.createDelegate(this));
    }

    var name_field_config = {xtype: 'textfield', itemId: 'name_field', fieldLabel: 'Name', value: mode != 'new' ? (mode == 'copy' ? 'Copy of ' : '') + record.get('name') : '' };
    
    if(mode === 'new'){
      var json_store = new Ext.data.JsonStore({
          url: '/vms/scenarios/' + this.scenarioId + '/sites/existing',
          idProperty: 'id',
          root: 'sites',
          fields: ['name', 'lat', 'lng', 'id', 'address']
      });
      Ext.apply(name_field_config, {xtype: 'combo', queryParam: 'name',
          mode: 'remote', triggerAction: 'query', 
          store: json_store, displayField: 'name', valueField: 'name',
          tpl:'<tpl for="."><div ext:qtip=\'{address}\' class="x-combo-list-item">{name}</div></tpl>',
          minChars: 0,
          listeners: {
            scope: this,
            'select': function(combo, r, index){
              mode = 'activate';
              record = new (this.siteGrid.getStore().recordType)({status: 'active', type: 'site'});
              record.id = r.get('id');
              record.set('id', r.get('id'));
              record.set('name', r.get('name'));
              record.set('address', r.get('address'));
              record.set('lat', r.get('lat'));
              record.set('lng', r.get('lng'));
              win.getComponent('address_field').setValue(r.get('address'));
            }
          }});
    }

    var win = new Talho.VMS.ux.ItemDetailWindow({
      items: [
        name_field_config,
        {xtype: 'textfield', itemId: 'address_field', fieldLabel: 'Address', value: original_address}
      ],
      listeners:{
        scope: this,
        'save': function(win){
          var store = this.siteGrid.getStore();
          var addr = win.getComponent('address_field').getValue();
          var name = win.getComponent('name_field').getRawValue();
          
          var rec = mode == 'activate' ? record : new store.recordType({status: 'active', type: 'site'});
          if(mode != 'activate' || store.indexOf(rec) === -1)
            store.add(rec);
          else
            rec.set('status', 'active');
          
          rec.set('address', addr);
          rec.set('name', name);
          
          var add_marker_local = function(loc){
            rec.set('lat', loc.lat());
            rec.set('lng', loc.lng());
            
            Ext.Ajax.request({
              method: mode == 'activate' ? 'PUT' : 'POST',
              url: '/vms/scenarios/' + this.scenarioId + '/sites' + (mode == 'activate' ? '/' + rec.get('id') : ''),
              scope: this,
              params: {
                'site[name]': rec.get('name'),
                'site[address]': rec.get('address'),
                'site[lat]': rec.get('lat'),
                'site[lng]': rec.get('lng'),
                'status': rec.get('status') === 'active' ? 2 : 1
              },
              success: function(response){
                var resp = Ext.decode(response.responseText);
                var id = resp.site.site_id;
                rec.set('id', id);
                rec.id = id;
                this.map.addMarker(loc, rec.get('name'), {record: rec});
                this.siteGrid.getStore().commitChanges();
                win.close();                
              },
              failure: function(){
                Ext.Msg.alert('There was an error saving the site');
                win.close();
              }
            });
          }.createDelegate(this);
          
          if(addr != original_address){
            this.map.geocoder.geocode({address: addr}, function(results, status){
              add_marker_local(results[0].geometry.location);
            });
          }
          else {
            add_marker_local(latLng);
          }
        }
      }      */