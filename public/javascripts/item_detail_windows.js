Ext.ns('Talho.VMS.ux');

Talho.VMS.ux.ItemDetailWindow = Ext.extend(Ext.Window, {
  layout: 'form',
  height: 300,
  width: 400,
  modal: true,
  constructor: function(config){
    this.addEvents(
      /**
       * @event save
       * Fires when the save button is clicked. Override onSaveClicked to add more arguments.
       * @param {Window} this 
       */
      'save');
    this.masks = {};
    Ext.apply(config, {buttons: [{text: 'Save', scope: this, handler: this.onSaveClicked}, {text: 'Cancel', scope: this, handler: function(){this.close();} } ]});
    Talho.VMS.ux.ItemDetailWindow.superclass.constructor.apply(this, arguments);
  },
  
  /**
   * Override to provide arguments to event "save"
   */
  onSaveClicked: function(){
    this.fireEvent('save', this);
  },
  
  showMask: function(label){
    if(Ext.isEmpty(label)) label = 'Saving...';
    var mask = this.masks[label];
    if(!mask){
      this.masks[label] = new Ext.LoadMask(this.getLayoutTarget(), {msg: label});
    }
    this.current_mask = this.masks[label];
    this.current_mask.show();
    Ext.each(this.buttons, function(button){button.disable();});
  },
  
  hideMask: function(){
    if(this.current_mask) this.current_mask.hide();
    Ext.each(this.buttons, function(button){button.enable();});
  }
});
