module Haki
  #Type should be like HypervisorType::VMX_04, from jcloud-abiquo
  def create_vdcs context, n, type
    infra = InfrastructureController.new context
    cloud = CloudController.new context
    
    dc = infra.list_dcs[0]
    ent = infra.list_enterprises[0]
    
    #Create vApps in a random VDC
    vdcs = []
    for i in 1..n.to_i
      vdcs << cloud.create_virtual_datacenter(dc, ent, type, "vdc_#{i}", "default", "192.168.0.0", 24, "192.168.0.1")
    end
    vdcs
  end
  
  #Create randomly N vapps in a VDCs pool
  def create_vapps context, n, vdcs_pool = nil
    cloud = CloudController.new context
    
    #Get VDCs
    vdcs = (vdcs_pool || cloud.list_virtual_datacenters())
    
    #Create vApps
    vapps = []
    for i in 1..n.to_i
      vapps << cloud.create_virtual_appliance(vdcs[rand(vdcs.length)], "vapp_#{i}")
    end
    vapps
  end
  
  def create_nodes context, n, vapp, template
    cloud = CloudController.new context
    
    #Get vApp's VDC
    vdc = vapp.getVirtualDatacenter

    #Get template
    t = cloud.find_template(vdc, template)
    raise Exception.new "Template with name #{template} not found for the VDC" unless t
    
    #Create VirtualMachines
    vms = []
    for i in 1..n.to_i
      vms << cloud.create_virtual_machine(vapp, t) if t
    end
    vms
  end
end
