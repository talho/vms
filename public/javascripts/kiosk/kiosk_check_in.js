Ext.ns("Talho.VMS");

(function(){

  var getAvailableHeight = function(){
    return Ext.getDoc().getViewSize(false).height - Ext.get('vms-kiosk-header').getHeight() -10;
  };
  
  var doResize = function() {
    Ext.getCmp('vms-kiosk-main-ext-panel').setHeight( getAvailableHeight() );
  };

  var kiosk = Ext.extend(Ext.util.Observable, {

    clearPassword: function(){ this.signinPasswordField.setValue(null); },

    clearEmail: function(){ this.signinEmailField.setValue(null); },

    setCheckinButtonLabel: function(label_text){
      this.checkInOutButton.setText('<span style="font-size: 150%; font-weight: bold;">&nbsp;&nbsp;' + label_text +  '&nbsp;&nbsp;</span>')
    },

    registeredCheckin: function(form){
      this.checkInOutButton.disable();
      var params = {'scenario_site_id':SCENARIO_SITE_ID};
      var record = this.volunteersGrid.getSelectionModel().getSelected();
      if (record != null && record.data['type'] == 'walkup' ){
       // params['walkup_signout'] = true;
        params['walkup_id'] = record['id'];
      }
      form.getForm().submit({
        params: params,
        scope: this,
        success: function(){
         this.signInForm.getForm().reset();
         this.checkInOutButton.enable();
         this.siteVolunteersStore.load();
        },
        failure: function(){
         this.clearPassword();
         this.checkInOutButton.enable();
         Ext.Msg.alert('Error', 'Invalid Email or Password. <br> Please try again.');
        }
      })
    },

    invalidBlankField: function(text_field){ // returns false if the field is blank
      if (text_field.getValue() == ''){
        text_field.markInvalid('Required');
        return false;
      } else {
        return true;
      }
    },

    walkupCheckin: function(form, new_user_form){
      //manual validation here because of some timing weirdness with resetForm/clearInvalid and allowBlank:true
      var valid = (this.invalidBlankField(this.walkupFirstNameField) & this.invalidBlankField(this.walkupLastNameField));
      var params = {};
      if ( this.walkupNewUserCheckbox.getValue() ){
        valid = (this.invalidBlankField(this.walkupPasswordField) & this.invalidBlankField(this.walkupPasswordConfirmField) & this.invalidBlankField(this.walkupEmailField));
        params = new_user_form.getForm().getValues();
      }
      if (valid) {
        this.walkupCheckinButton.disable();
        params['scenario_site_id'] = SCENARIO_SITE_ID;
        form.getForm().submit({
          scope: this,
          params: params,
          success: function(){
            this.walkupForm.getForm().reset();
            this.walkupCheckinButton.enable();
            this.siteVolunteersStore.load();
            Ext.Msg.alert('Success', 'You have been checked in.<br> Please remember to check out before you leave.');
          },
          failure: function(){
            this.walkupCheckinButton.enable();
            Ext.Msg.alert('Error', "We're sorry, an error has occured");
          }
        })
      }
    },

    setSigninFormMode: function(mode){
      switch(mode){
        case 'walkup':
          this.signinEmailField.setValue('Walk-Up Volunteer');
          this.signinPasswordField.setValue('no password');
          this.signinEmailField.disable();
          this.signinPasswordField.disable();
          this.resetCheckinButton.show();
          break;
        default:
          this.signinEmailField.enable();
          this.signinPasswordField.enable();
          this.resetCheckinButton.hide();
      }
    },

    showTimeoutNotice: function(error_msg){
      this.refresherIntervalLabelHead.hide();
      this.refresherSlider.hide();
      this.refresherIntervalLabelTail.hide();
      this.stoppedMessage.setText(error_msg);
      this.stoppedMessage.show();
    },

    hideTimeoutNotice: function(){
      this.refresherIntervalLabelHead.show();
      this.refresherSlider.show();
      this.refresherIntervalLabelTail.show();
      this.stoppedMessage.hide();
    },

    DEFAULT_REFRESHER_INTERVAL: 60,
    VOLUNTEER_REFRESH_MAX: 60,
    volunteer_refresh_count: 0,
    VOLUNTEER_EXCEPTION_MAX: 3,
    volunteer_exception_count: 0,

    stopVolunteerRefresher: function(){
      this.volunteer_refresh_count = 0;
      if (this.volunteer_refresher) { 
        clearInterval(this.volunteer_refresher);
        this.volunteer_refresher = null;
        this.volunteerRefresherStartButton.show();
        this.volunteerRefresherStopButton.hide();
      }
    },

    startVolunteerRefresher: function(){
      this.volunteer_exception_count = 0;
      if (this.volunteer_refresher) {
        clearInterval(this.volunteer_refresher);
      }
      if (this.volunteer_refresh_count < this.VOLUNTEER_REFRESH_MAX){
        var inst = this;   // make a copy of 'this' to pass into the interval timer because it runs /IN SPAAAAAAACE/
        this.volunteer_refresher = setInterval(function(){ inst.siteVolunteersStore.load(); }, this.refresherSlider.getValue() * 1000);
        this.volunteer_refresh_count += 1;
        this.volunteerRefresherStopButton.show();
        this.volunteerRefresherStartButton.hide();
        this.hideTimeoutNotice();
      } else {
        this.stopVolunteerRefresher();
        this.showTimeoutNotice('Auto-refreshing stopped (Refresh limit)');
      }
    },

    handleVolunteerException: function(){
      this.volunteer_exception_count += 1;
      if (this.volunteer_exception_count > this.VOLUNTEER_EXCEPTION_MAX){
        this.stopVolunteerRefresher();
        this.showTimeoutNotice('Auto-refreshing stopped (Could not contact server)');
      }
    },

    init: function(){
      this.siteVolunteersStore = new Ext.data.JsonStore ({
        url: document.location.href + '.json', restful: true, root: 'volunteers', autoLoad: true,
        fields: ['id', 'display_name', 'image', 'email', 'type', 'checked_in', 'scenario_site_admin'] ,
        listeners: {
          scope: this,
          'load':      function(){ this.startVolunteerRefresher(); },
          'exception': function(){ this.handleVolunteerException(); }
        }
      });

      this.volunteerTemplate = new Ext.XTemplate(
        '<div style="width: 70px; height: 55px; float:left;"><img src="{image}"></div>' +
        '<div style="float: left; padding-top: 20px; font-weight: bold; font-size: 200%;">{display_name}<tpl if="scenario_site_admin"> - <span style="color: green;">Site Admin</span></tpl></div>' +
        '<div style="float: right;"><img src="/stylesheets/vms/images/check-box<tpl if="checked_in">-checked</tpl>.png"></div>'
      );

      this.refresherSlider = new Ext.Slider ({
        value: this.DEFAULT_REFRESHER_INTERVAL,
        width: 100, increment: 5, minValue: 10, maxValue: 90,
        listeners: {
          scope: this,
          'change': function(){
            this.refresherIntervalLabelTail.setText(this.refresherSlider.getValue() + ' seconds');
            this.stopVolunteerRefresher();
            this.startVolunteerRefresher();
          }
        }
      });

      this.stoppedMessage = new Ext.Toolbar.TextItem({
        style: {'color': 'black'}, hidden: true, text: ''
      });

      this.refresherIntervalLabelHead = new Ext.Toolbar.TextItem({
        style: {'color': 'black'}, text: 'Auto-refreshing every '
      });

      this.refresherIntervalLabelTail = new Ext.Toolbar.TextItem({
        style: {'color': 'black'},
        text: this.DEFAULT_REFRESHER_INTERVAL + ' seconds'
      });

      this.volunteerRefresherStartButton = new Ext.Button({
        text: '<span style="font-weight: bold;">Start</span>', scope: this, hidden: true, handler: function(){ this.startVolunteerRefresher(); }
      });

      this.volunteerRefresherStopButton = new Ext.Button({
        text: '<span style="font-weight: bold;">Stop</span>', scope: this, handler: function(){ this.stopVolunteerRefresher(); }
      });

      this.volunteersTbar = new Ext.Toolbar({
        items: [
          {text: '<span style="font-weight: bold;">Refresh</span>', scope: this, handler: function(){ this.siteVolunteersStore.load();} },
          '->',
          this.refresherIntervalLabelHead,
          this.refresherSlider,
          this.refresherIntervalLabelTail,
          this.stoppedMessage,
          this.volunteerRefresherStartButton,
          this.volunteerRefresherStopButton
        ]
      });

      this.volunteersGrid = new Ext.grid.GridPanel ({
        store: this.siteVolunteersStore,
        loadMask: true, region: 'center', itemId:'volunteers_list', border: false, hideHeaders: true, autoExpandColumn: 'volunteer', trackMouseOver: false,
        selModel: new Ext.grid.RowSelectionModel({ singleSelect: true }),
        colModel: new Ext.grid.ColumnModel({
          columns: [ { id: 'volunteer', dataIndex: 'id', sortable: false, xtype: 'templatecolumn', tpl: this.volunteerTemplate} ]
        }),
        viewConfig: {
          forceFit: true,
          getRowClass: function(record, index) {
            if (record.get('checked_in')) { return 'vms-checked-in'; }
          }
        },
        tbar: this.volunteersTbar,
        listeners: {
          scope: this,
          'rowclick': function(grid, row, column, e){
            var record = grid.getStore().getAt(row);  // Get the Record
            this.signinEmailField.setValue(record.data['email']);
            this.clearPassword();
            if (record.data['checked_in']){ this.setCheckinButtonLabel('Check Out'); } else { this.setCheckinButtonLabel('Check In'); }
            if (record.data['type'] == 'walkup'){ this.setSigninFormMode('walkup'); } else { this.setSigninFormMode('registered'); }
            this.walkupForm.getForm().reset();
          }
        }
      });

      this.signinEmailField = new Ext.form.TextField({
        id:'email', name:'email', inputType:'text', fieldLabel:'Email Address', enableKeyEvents: true, labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'95%', style:{'fontSize':'150%'},
        listeners: {
          scope: this,
          'keypress': function(){ this.volunteersGrid.getSelectionModel().clearSelections(); this.setCheckinButtonLabel('Check In'); },
          'focus': function(){ this.walkupForm.getForm().reset(); this.signinEmailField.clearInvalid(); }
        } });

      this.signinPasswordField = new Ext.form.TextField({
        id:'password', name:'password', inputType:'password', fieldLabel:'Password', labelStyle: 'text-align: right; font-weight:bold;', height: 35, anchor:'95%', style:{'fontSize':'300%'},
        listeners: { scope: this, 'focus': function(){ this.walkupForm.getForm().reset(); } }
      });

      this.checkInOutButton =  new Ext.Button({text: '<span style="font-size: 150%; font-weight: bold;">&nbsp;&nbsp;Check In&nbsp;&nbsp;</span>',
        scale: 'large', scope: this, handler: function(){ this.registeredCheckin(this.signInForm); }
      });

      this.resetCheckinButton =  new Ext.Button({text: '<span style="font-size: 150%;">&nbsp;&nbsp;Reset&nbsp;&nbsp;</span>',
        scale: 'large', scope: this, hidden: true, handler: function(){ this.signInForm.getForm().reset(); }
      });

      this.signInForm = new Ext.FormPanel({
        url: '/vms/site_checkin.json', region: 'north', border: false, style: {'padding':'10px 0'}, bodyStyle: 'background-color: #DFE8F6;',
        items: [
          new Ext.form.DisplayField({ html: 'Please check in and out with your TxPhin Account', style:{'text-align': 'center', 'font-size':'150%'}, hideLabel: true}) ,
          this.signinEmailField,
          this.signinPasswordField
        ],
        buttonAlign: 'center',
        buttons: [ this.checkInOutButton, this.resetCheckinButton ],
        keys: [{key: Ext.EventObject.RETURN, shift: false, fn: function(){ this.registeredCheckin(this.signInForm) }, scope: this}]
      });

      this.walkupFirstNameField = new Ext.form.TextField({
        id:'walkup_first_name', name:'walkup_first_name', inputType:'text', fieldLabel:'First Name', labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'90%', style:{'fontSize':'150%'},
        listeners: { scope: this, 'focus': function(){ this.walkupFirstNameField.clearInvalid(); this.signInForm.getForm().reset(); } }
      });
      this.walkupLastNameField = new Ext.form.TextField({
        id:'walkup_last_name', name:'walkup_last_name', inputType:'text', fieldLabel:'Last Name', labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'90%', style:{'fontSize':'150%'},
        listeners: { scope: this, 'focus': function(){ this.walkupLastNameField.clearInvalid();  this.signInForm.getForm().reset(); } }
      });
      this.walkupEmailField = new Ext.form.TextField({
        id:'walkup_email', name:'walkup_email', inputType:'text', fieldLabel:'Email Address', labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'90%', style:{'fontSize':'150%'}, vtype: 'email',
        listeners: { scope: this, 'focus': function(){ this.signInForm.getForm().reset(); this.walkupEmailField.clearInvalid(); } }
      });
      this.walkupNewUserCheckbox = new Ext.form.Checkbox({ boxLabel: 'Create a TxPhin Account?', name: 'walkup_new_account', checked: true,
        listeners:{ scope: this,
          'check': function(box,checked){
            if (checked) {
              this.walkupNewUserForm.enable();
            } else {
              this.walkupNewUserForm.getForm().reset();
              this.walkupNewUserForm.disable();
              this.walkupEmailField.clearInvalid();
            } } } });
      this.walkupPasswordField = new Ext.form.TextField({
        id:'walkup_password', name:'walkup_password', inputType:'password', fieldLabel:'New Password', labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'70%', style:{'fontSize':'150%'}, vtype: 'password',
        listeners: {scope: this, 'focus': function(){ this.walkupPasswordField.clearInvalid(); } }
      });
      this.walkupPasswordConfirmField = new Ext.form.TextField({
        id:'walkup_password_confirm', name:'walkup_password_confirm', inputType:'password', fieldLabel:'Confirm Password', labelStyle: 'text-align: right; font-weight:bold;',
        height: 35, anchor:'70%', style:{'fontSize':'150%'}, vtype: 'password', initialPassword:'walkup_password',
        listeners: {scope: this, 'focus': function(){ this.walkupPasswordConfirmField.clearInvalid(); } }
      });
      this.walkupCheckinButton =  new Ext.Button({text: '<span style="font-size: 150%; font-weight: bold;">&nbsp;&nbsp;Check In&nbsp;&nbsp;</span>',
        scale: 'large', scope: this, handler: function(){ this.walkupCheckin(this.walkupForm, this.walkupNewUserForm); }
      });

      this.walkupNewUserForm = new Ext.FormPanel({
        border: false, bodyStyle: 'padding: 10px 0',
        items: [
          this.walkupPasswordField,
          this.walkupPasswordConfirmField,
          new Ext.form.DisplayField({ html: "Passwords must have at least 8 characters, one Capital and one number", style:{'text-align': 'center',  'font-style':'italic'}, hideLabel: true})
        ]
      });

      this.walkupForm = new Ext.FormPanel({
        url: '/vms/site_walkup.json',
        border: false,
        items: [
          new Ext.form.DisplayField({ html: "Don't have a TxPhin Account?  <br>Please enter your name.", style:{'text-align': 'center', 'padding':'10px 0 10px 0', 'font-size':'150%'}, hideLabel: true}),
          this.walkupFirstNameField,
          this.walkupLastNameField,
          this.walkupEmailField,
          this.walkupNewUserCheckbox,
          this.walkupNewUserForm
        ],
        buttonAlign: 'center',
        buttons: [ this.walkupCheckinButton ]
      });

      this.leftPanel = new Ext.Panel ({
        layout: 'border', title: 'Registered Volunteers', flex: 1.2, autoScroll: false,
        items: [ this.signInForm, this.volunteersGrid ]
      });

      this.rightPanel = new Ext.Panel ({
        resize: true, border: true, flex: 0.8, margins: '0 5 0 30',
        items: [ this.walkupForm ]
      });

      this.checkInPanel = new Ext.Panel({
        layout: 'hbox', id: 'vms-kiosk-main-ext-panel', border: false, padding: 10,
        renderTo: TARGET_DIV_ID, layoutConfig: {align: 'stretch'},
        height: getAvailableHeight(),
        items: [ this.leftPanel, this.rightPanel ]
      });
    }
  });

  Ext.EventManager.onWindowResize(doResize);
  Talho.VMS.kiosk = new kiosk();

})();