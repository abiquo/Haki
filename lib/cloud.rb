import org.jclouds.abiquo.domain.network.PrivateNetwork
import org.jclouds.abiquo.domain.cloud.VirtualDatacenter
import org.jclouds.abiquo.domain.cloud.VirtualAppliance
import org.jclouds.abiquo.domain.cloud.VirtualMachine
import org.jclouds.abiquo.domain.cloud.VirtualMachineTemplate

import org.jclouds.abiquo.predicates.cloud.VirtualDatacenterPredicates
import org.jclouds.abiquo.predicates.cloud.VirtualAppliancePredicates
import org.jclouds.abiquo.predicates.cloud.VirtualMachinePredicates
import org.jclouds.abiquo.predicates.cloud.VirtualMachineTemplatePredicates

module Haki
  class CloudController
    def initialize(context)
      @context = context
    end
    def create_virtual_datacenter(datacenter, enterprise, type, name, netname, netaddress, netmask, netgateway)
      network = PrivateNetwork.builder(@context) \
                  .name(netname) \
                  .address(netaddress) \
                  .mask(netmask) \
                  .gateway(netgateway) \
                  .build()
      vdc = VirtualDatacenter.builder(@context, datacenter, enterprise) \
              .name(name) \
              .hypervisorType(type) \
              .network(network) \
              .build()
      vdc.save()
      vdc
    end
    
    def get_virtual_datacenter(name)
      cloud = @context.getCloudService()
      cloud.findVirtualDatacenter(VirtualDatacenterPredicates.name(name))
    end
    
    def list_virtual_datacenters()
      cloud = @context.getCloudService()
      cloud.listVirtualDatacenters()
    end
    
    def delete_virtual_datacenter(name)
      vdc = get_virtual_datacenter(name)
      vdc.delete()
    end
    
    def create_virtual_appliance(vdc, name)
      vapp = VirtualAppliance.builder(@context, vdc) \
             .name(name) \
             .build()
      vapp.save()
      vapp
    end

    def get_virtual_appliance(name)
      cloud = @context.getCloudService()
      cloud.findVirtualAppliance(VirtualAppliancePredicates.name(name))
    end
    
    def list_virtual_appliances()
      cloud = @context.getCloudService()
      cloud.listVirtualAppliances()
    end

    def delete_virtual_appliance(name)
      vapp = get_virtual_appliance(name)
      vapp.delete()
    end
    
    def create_virtual_machine(vapp, template)
      vm = VirtualMachine.builder(@context, vapp, template).build()
      vm.save()
      vm
    end

    def get_virtual_machine(name)
      cloud = @context.getCloudService()
      cloud.findVirtualMachine(VirtualMachinePredicates.name(name))
    end
    
    def list_virtual_machines()
      cloud = @context.getCloudService()
      cloud.listVirtualMachines()
    end
    
    def delete_virtual_machine(vapp, name)
      vm = get_virtual_machine(vapp, name)
      vm.delete()
    end
    
    def refresh_template_repository(enterprise, datacenter)
      enterprise.refreshTemplateRepository(datacenter)
    end
    
    def find_template(vdc, name)
      vdc.findAvailableTemplate(VirtualMachineTemplatePredicates.name(name))
    end
    
    def list_templates(vdc)
      vdc.listAvailableTemplates()
    end
  end
end