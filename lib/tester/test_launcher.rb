module Haki
  
  HYPERVISOR_TYPE = {
    "esxi" => HypervisorType::VMX_04,
    "kvm" => HypervisorType::KVM,
    "xen" => HypervisorType::XEN_3,
    "hyperv" => HypervisorType::HYPERV_301,
    "xenserver" => HypervisorType::XENSERVER,
    "vbox" => HypervisorType::VBOX
  }

  class CloudTest
    attr_reader :vdcs, :vapps, :vms
    def initialize params

      @endpoint = "http://#{params['endpoint']['ip']}/api"
      @endpoint_user = params['endpoint']['user']
      @endpoint_pass = params['endpoint']['password']


      @num_vdcs = params['test']['vdcs']
      @num_vapps = params['test']['vapps']
      @num_vms = params['test']['vms']
      @hypervisor = params['test']['hypervisor']
      @template_name = params['test']['template']

      @context = create_context(@endpoint, @endpoint_user, @endpoint_pass)
    end

    def context
      @context ||= create_context(@endpoint, @endpoint_user, @endpoint_pass)
    end
    
    def create
      hyp_type = nil    
      if @hypervisor
        hyp_type = HYPERVISOR_TYPE[@hypervisor]
      else
        infra = InfrastructureController.new context
        hyp_type = infra.list_machines.to_a.sample.getType
      end

      raise Exception.new "Not a valid hypervisor type: #{hyp_type}" unless hyp_type

      #Create vdcs
      create_vdcs(context, @num_vdcs, hyp_type)
      
      #Create vapps
      vapps = create_vapps(context, @num_vapps)
  
      #Add nodes to Vapps
      vapps.each do |vapp|
        #if template name not specified in the test specs, choose a random one
        template_name_temp = ''
        if not @template_name
          cloud = CloudController.new context
          template_name_temp = cloud.list_templates(cloud.list_virtual_datacenters[0]).to_a.sample.getName
        end
        create_nodes(context, @num_vms, vapp, @template_name || template_name_temp)
      end
    end
    
    def deploy
      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()

      return false if vapps.empty?
      vapps.each {|vapp| vapp.deploy()}
      true
    end

    #Only awaits until deploy tasks finish. Its possible that the deploy has failed
    def await_end_deploy
      monitor = context.getMonitoringService().getVirtualApplianceMonitor()
      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()

      vapps.each {|vapp| monitor.awaitCompletionDeploy(vapp)}
      true
    end
    
    def status
      deployed_vapps = 0
      undeployed_vapps = 0
      deployed_vms = 0
      undeployed_vms = 0
      
      status = {:vms => {}, :vapps => {}}

      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()
      vms = cloud.list_virtual_machines()
      
      return status if vms.empty? or vapps.empty?
      
      vms.each {|vm| status[:vms][vm.getName().to_s] = vm.getState().to_s}
      
      vapps.each {|vapp| status[:vapps][vapp.getName().to_s] = vapp.getState().to_s}
      
      return status
    end
  
    def undeploy
      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()
      return false if vapps.empty?

      #Undeploy vapps and vms
      vapps.each {|vapp| vapp.undeploy()}
    end
    
    def destroy
      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()
      vdcs = cloud.list_virtual_datacenters()
      
      vapps.each {|vapp| vapp.delete()} if vapps
      vdcs.each {|vdc| vdc.delete()} if vdcs

    end
    
    #Only awaits until undeploy tasks finish. Its possible that the undeploy has failed
    def await_end_undeploy
      monitor = context.getMonitoringService().getVirtualApplianceMonitor()
      cloud = Haki::CloudController.new context
      vapps = cloud.list_virtual_appliances()
      
      vapps.each {|vapp| monitor.awaitCompletionUndeploy(vapp)}
    end
  end
end