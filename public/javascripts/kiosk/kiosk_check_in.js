Ext.ns("Talho.VMS");

(function(){

  var TARGET_DIV_ID = 'checkin-ext-wrapper';

  var getAvailableHeight = function(){
    return Ext.getDoc().getViewSize(false).height - Ext.get('vms-kiosk-header').getHeight();
  };
  
  var doResize = function() {
    Ext.getCmp('vms-kiosk-main-ext-panel').setHeight( getAvailableHeight() );
  };

  var kiosk = Ext.extend(Ext.util.Observable, {
     init: function(){
      this.siteVolunteersStore = new Ext.data.JsonStore ({
        url: '/vms_kiosks/1.json',
        restful: true,
        root: 'volunteers',
        fields: ['display_name', 'id', 'image', 'email'],
        autoLoad: true
      });

      this.signinEmailField = new Ext.form.TextField({ id:'email', name:'email', inputType:'text', fieldLabel:'Email Address', height: 35, anchor:'100%', style:{'fontSize':'150%'} });
      this.signinPasswordField = new Ext.form.TextField({ id:'password', name:'password', inputType:'password', fieldLabel:'Password', height: 35, anchor:'100%', style:{'fontSize':'150%'}  });

      this.unassignedSignInForm = new Ext.FormPanel({
        region: 'south',
        border: false,
        style: {'backgroundColor': '#DFE8F6'},

        margins: '10 10 10 10',
        items: [
          new Ext.form.DisplayField({ html: 'Please check in with your TxPhin Account', style:{'font-size':'150%'}, hideLabel: true}) ,
          this.signinEmailField,
          this.signinPasswordField
        ],
        buttonAlign: 'center',
        buttons: [
          new Ext.Button({text: '<span style="font-size: 150%; font-weight: bold;">&nbsp;&nbsp;Check In&nbsp;&nbsp;</span>', scale: 'large'})
        ]
      });

      this.volunteerTemplate = new Ext.XTemplate(
        '<div style="width: 70px; height: 55px; float:left;"><img src="{image}"></div><div style="float: left; padding-top: 20px; font-weight: bold; font-size: 200%;">{display_name}</div>'
      );

      this.volunteersList = new Ext.grid.GridPanel ({
        store: this.siteVolunteersStore,
        autoExpandColumn: 'volunteer',
        region: 'center',
        hideHeaders: true,
        border: false,
        loadMask: true,
        colModel: new Ext.grid.ColumnModel({
          columns: [ { id: 'volunteer', dataIndex: 'id', sortable: false, xtype: 'templatecolumn', tpl: this.volunteerTemplate} ]
        }),
        listeners: {
          scope: this,
          'rowclick': function(grid, row, column, e){
            var record = grid.getStore().getAt(row);  // Get the Record
            this.signinEmailField.setValue(record.data['email']);
          }
        }
      });

      this.registeredVolunteersPanel = new Ext.Panel ({
        layout: 'border',
        title: "Registered Volunteers",
        flex: 1,
        autoScroll: false,
        items: [this.volunteersList, this.unassignedSignInForm]
      });

      this.walkupSignupPanel = new Ext.Panel ({
        layout: 'fit',
        title: "Walk-Up Volunteers",
        flex: 1,
        margins: '0 0 0 10',
        items: [{html: "pong", border: false}]
      });

      this.checkInPanel = new Ext.Panel({
        layout: 'hbox',
        height: getAvailableHeight(),
        renderTo: TARGET_DIV_ID,
        layoutConfig: {align: 'stretch'},
        id: 'vms-kiosk-main-ext-panel',
        border: false,
        padding: 10,
        items: [ this.registeredVolunteersPanel, this.walkupSignupPanel ]
      });
    }
  });

  Ext.EventManager.onWindowResize(doResize);
  Talho.VMS.kiosk = new kiosk();

})();