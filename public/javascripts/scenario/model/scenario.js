Ext.ns('Talho.VMS.Scenario.Model')

Talho.VMS.Scenario.Model.Scenario = Ext.data.Record.create(['id', 'name', 
  {name: 'state', convert: function(v){
      switch(v){
        case 1: return 'Template';
        case 2: return 'Unexecuted';
        case 3: return 'In Progress';
        case 4: return 'Paused';
        case 5: return 'Completed';
      }
    }
  }, 'user_rights', 'site_instances', 
  {name: 'created_at', type: 'date'}, 
  {name: 'updated_at', type: 'date'}, 
  {name:'used_at', type: 'date'}]);
