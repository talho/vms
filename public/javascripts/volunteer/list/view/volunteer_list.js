/**
 * @author Charles DuBose
 */

Ext.ns('Talho.VMS.Volunteer.List.View')

Talho.VMS.Volunteer.List.View.VolunteerList = Ext.extend(Ext.grid.GridPanel, {
  initComponent: function(){
    var sm = new Ext.grid.RowSelectionModel({
      singleSelect: this.chooseMode ? false : true
    });
    if(this.chooseMode){
      sm.handleMouseDown = function(g, rowIndex, e){
          if(e.button !== 0 || this.isLocked()){
              return;
          }
          var view = this.grid.getView();
          if(e.shiftKey && !this.singleSelect && this.last !== false){
              var last = this.last;
              this.selectRange(last, rowIndex, e.ctrlKey);
              this.last = last; // reset the last
              view.focusRow(rowIndex);
          }else{
              var isSelected = this.isSelected(rowIndex);
              if(isSelected){
                  this.deselectRow(rowIndex);
              }else if(!isSelected || this.getCount() > 1){
                  this.selectRow(rowIndex, true);
                  view.focusRow(rowIndex);
              }
          }
      };
    }
    
    Ext.apply(this, {
      store: new Ext.data.JsonStore({
        fields: Talho.VMS.Model.Volunteer, 
        idProperty: 'id', 
        url: '/vms/volunteers.json', 
        autoLoad: true,
        totalProperty: 'total',
        root: 'vols'
      }),
      loadMask: true,
      columns: [{header: 'Name', dataIndex: 'name', id: 'name_column'}],
      autoExpandColumn: 'name_column',
      sm: sm
    });
    
    if(this.chooseMode){
      this.buttons = [
        {text: 'Select All', scope: this, handler: function(){this.getSelectionModel().selectAll();}},
        {text: 'Select None', scope: this, handler: function(){this.getSelectionModel().clearSelections();}}
      ];
    }
    
    Talho.VMS.Volunteer.List.View.VolunteerList.superclass.initComponent.apply(this, arguments);
    
    if(this.chooseMode){
      this.getStore().on('load', function(){this.getSelectionModel().selectAll();}, this, {delay: 10, once: true});
    }
  }
});

Ext.reg('volunteerlist', Talho.VMS.Volunteer.List.View.VolunteerList);
