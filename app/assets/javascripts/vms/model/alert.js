Ext.ns('Talho.VMS.Model');

Talho.VMS.Model.Alert = Ext.data.Record.create(['id', 'name', 'message', 'author', 'scenario_name', 'call_down_response', 'calldowns', 'created_at', 'acknowledge', 'acknowledged_at', 'alert_type']);
