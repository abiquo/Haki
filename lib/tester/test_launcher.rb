module Haki
  class CloudTest
    attr_reader :vdcs, :vapps, :vms, :context
    def initialize params
      @endpoint = "http://#{params[:endpoint_ip]}/api"
      @endpoint_user = params[:user]
      @endpoint_pass = params[:pass]
      @num_vdcs = params[:num_vdcs]
      @num_vapps = params[:num_vapps]
      @num_vms = params[:num_vms]
      @hyp_type = params[:hyp_type]
      @template = params[:template]
      @vdcs = []
      @vapps = []
      @vms = []
    end
    def context
      @context || @context = create_context(@endpoint, @endpoint_user, @endpoint_pass)
    end
    
    def create
      @context = create_context(@endpoint, @endpoint_user, @endpoint_pass)

      #Create vdcs
      @vdcs = create_vdcs(context, @num_vdcs, @hyp_type)
      
      #Create vapps
      @vapps = create_vapps(context, @num_vapps)
  
      #Add nodes to Vapps
      @vapps.each {|vapp| @vms += create_nodes(context, @num_vms, vapp, @template)}
    end
    
    def deploy
      return if @vapps.empty?
      @vapps.each {|vapp| vapp.deploy()}
    end
    
    def await_end_deploy
      monitor = @context.getMonitoringService().getVirtualApplianceMonitor()
      
      @vapps.each {|vapp| monitor.awaitCompletionDeploy(vapp)}
    end
    
    def status
      deployed_vapps = 0
      undeployed_vapps = 0
      deployed_vms = 0
      undeployed_vms = 0
      
      status = {:vms => {}, :vapps => {}}
      
      return status if @vms.empty? or @vapps.empty?
      
      @vms.each {|vm| status[:vms][vm.getName().to_s] = vm.getState().to_s}
      
      @vapps.each {|vapp| status[:vapps][vapp.getName().to_s] = vapp.getState().to_s}
      
      return status
    end
  
    def undeploy
      return if @vapps.empty?

      #Undeploy vapps and vms
      @vapps.each {|vapp| vapp.undeploy()}      
    end
    
    def destroy
      return if @vapps.empty?
      
      @vapps.each {|vapp| vapp.delete()}
      @vdcs.each {|vdc| vdc.delete()}
      @vdcs = []
      @vapps = []
      @vms = []
      @context.close
    end
    
    def await_end_undeploy
      monitor = @context.getMonitoringService().getVirtualApplianceMonitor()
      
      @vapps.each {|vapp| monitor.awaitCompletionUndeploy(vapp)}
    end
  end
end