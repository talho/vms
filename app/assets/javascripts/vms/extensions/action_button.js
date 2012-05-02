Ext.ns('Talho.ux.ActionButton');

(function(){  
  var action_button_template = new Ext.XTemplate(
    '<div id="{2}" class="x-btn vms-tool-row vms-row-button">',
      '<div class="vms-row-icon {0}"></div>',
      '<div class="vms-row-text"><span class="{1}"></span></div>',
      '<div style="clear:both;">',
    '</div>',
    {compiled: true}
  );
  
  Talho.ux.ActionButton = Ext.extend(Ext.Button, {
    template: action_button_template, 
    buttonSelector: 'div.vms-row-text span', 
    getTemplateArgs: function(){return [this.iconCls, this.cls, this.id];}
  });
  
  Ext.reg('actionbutton', Talho.ux.ActionButton);
})();
