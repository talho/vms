Ext.ns('Talho.VMS.ux.CommandCenter');

Talho.VMS.ux.CommandCenter.ScenarioStatus = {
  beginExecution: function(){
    if(this.scenario_state === 'paused'){
      var win = new Talho.VMS.ux.ScenarioStatusChange({
        action: 'resume',
        scenarioId: this.scenarioId,
        scope: this,
        handler: function(btn, msg, custom_aud){
          var params = {};
          if(btn === 'yes'){
            params = {send_msg: true, custom_msg: msg, 'custom_aud[]': custom_aud};
          }
          this.changeScenarioState('execute', params, function(){
            this.scenario_state = 'executing';
            this.updateState();
          });
        }  
      });
      win.show();
    }
    else{
      var win = new Talho.VMS.ux.ScenarioStatusChange({
        action: 'execute',
        scenarioId: this.scenarioId,
        scope: this,
        handler: function(btn){
          if(btn === 'yes'){
            this.changeScenarioState('execute', {}, function(response, options){
              this.scenario_state = 'executing';
              
              var resp = Ext.decode(response.responseText);
              if(resp.scenario.id !== this.scenarioId){
                Ext.Direct.removeProvider('command_center_polling_provider-' + this.scenarioId);
                this.scenarioId = resp.scenario.id;
                this.buildPollingProvider();
              }
              
              this.updateState();
            });
          }
        }
      });
      win.show();
    }
  },
  
  pauseExecution: function(){
    var win = new Talho.VMS.ux.ScenarioStatusChange({
      action: 'pause', 
      scenarioId: this.scenarioId,
      scope: this,
      handler: function(btn, msg, custom_aud){
        var params = {};
        if(btn === 'yes'){
          params = {send_msg: true, custom_msg: msg, 'custom_aud[]': custom_aud};
        }
        this.changeScenarioState('pause', params, function(){
          this.scenario_state = 'paused';
          this.updateState();
        });
      }
    });
    win.show();
  },
  
  endExecution: function(){
    var win = new Talho.VMS.ux.ScenarioStatusChange({
      action: 'stop',
      scenarioId: this.scenarioId,
      scope: this,
      handler: function(btn, msg, custom_aud){
        if(btn === 'yes'){
          this.changeScenarioState('stop', {custom_msg: msg, 'custom_aud[]': custom_aud}, function(){
            this.scenario_state = 'ended';
            this.updateState();
          });
        }
      }
    });
    win.show();
  },
  
  changeScenarioState: function (to_state, additional_params, success, failure){
    failure = failure || function(resp){
      var result = Ext.decode(resp.responseText),
          msg = '';
      msg = "Could not change the state of the current scenario" + (Ext.isEmpty(result['msg']) ? '.' : (":<br/>" + result['msg']) );
      Ext.Msg.alert("Error", msg);
    }
    if(!this.saveMask) this.saveMask = new Ext.LoadMask(this.getLayoutTarget(), {msg: 'Saving...'});
    this.saveMask.show();
    Ext.Ajax.request({
      url: '/vms/scenarios/' + this.scenarioId + '/' + to_state + '.json',
      method: 'PUT',
      params: additional_params,
      success: function(){
        this.saveMask.hide();
        success.apply(this, arguments);
      },
      failure: function(){
        this.saveMask.hide();
        failure.apply(this, arguments);
      },
      scope: this
    });
  },
  
  updateState: function(){
    var pp = Ext.Direct.getProvider('command_center_polling_provider-' + this.scenarioId);
    if((this.scenario_state === 'executing' || this.scenario_state === 'paused') && !pp.isConnected()){
      pp.connect();
    }
    else if (pp.isConnected() && this.scenario_state !== 'executing') {
      pp.disconnect();
    }
    
    (['paused', 'unexecuted', 'template'].indexOf(this.scenario_state) !== -1) ? this.executeBtn.show() : this.executeBtn.hide();
    (['executing'].indexOf(this.scenario_state) !== -1) ? this.pauseBtn.show() : this.pauseBtn.hide();
    (['executing', 'paused'].indexOf(this.scenario_state) !== -1) ? this.endBtn.show() : this.endBtn.hide();
  },
  
  editScenario: function(){
    Application.on('vms-editscenarioclose', function(){
      if(this.loadMask) this.loadMask.show();
      Ext.Ajax.request({
        url: '/vms/scenarios/' + this.scenarioId,
        method: 'GET',
        success: this.loadScenario_success,
        scope: this
      });
    }, this, {single: true});
    
    Application.fireEvent('openwindow', {title:'Modify ' + this.scenarioName, scenarioId: this.scenarioId, scenarioName: this.scenarioName, source: 'command_center', initializer: 'Talho.VMS.CreateAndEditScenario'});
  },
  
  alertStaff: function(){
    var win = new Talho.VMS.ux.ScenarioStatusChange({
      action: 'alert',
      scenarioId: this.scenarioId,
      scope: this,
      handler: function(btn, msg, custom_aud){
        if(btn === 'ok'){
          this.changeScenarioState('alert', {custom_msg: msg, 'custom_aud[]': custom_aud}, function(){
            
          });
        }
      }
    });
    win.show();
  }
}
