module Vms::PopulateScenario

  private
  def initialize_scenario
    begin
      @scenario = Vms::Scenario.find(params[:vms_scenario_id])
    rescue Exception => e
      respond_to do |format|
        format.json {render :json => {:exception => e.message, :backtrace => e.backtrace, :error => "Could not find the requested scenario.", :success => false}, :status => 404}
      end
      false
    end
  end
end