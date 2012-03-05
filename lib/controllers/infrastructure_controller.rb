import org.jclouds.abiquo.domain.infrastructure.Datacenter
#import org.jclouds.abiquo.domain.infrastructure.Rack     #Conflicts with Rack middleware
import org.jclouds.abiquo.domain.infrastructure.Machine

import org.jclouds.abiquo.predicates.infrastructure.DatacenterPredicates
import org.jclouds.abiquo.predicates.infrastructure.RackPredicates
import org.jclouds.abiquo.predicates.infrastructure.MachinePredicates

import org.jclouds.abiquo.reference.AbiquoEdition

module Haki
  class InfrastructureController
    def initialize(context)
      @context = context
    end
    
    #DCs
    def create_dc(name, location, rs_address)
      datacenter = Datacenter.builder(@context) \
      .name(name) \
      .location(location) \
      .remoteServices(rs_address, AbiquoEdition::ENTERPRISE) \
      .build()
      
      datacenter.save()
      datacenter
    end
    
    def get_dc(name)
      administration = @context.getAdministrationService()
      administration.findDatacenter(DatacenterPredicates.name(name)) 
    end

    def list_dcs()
      administration = @context.getAdministrationService()
      administration.listDatacenters() 
    end
    
    def delete_dc(name)
      datacenter = get_dc(name)
      datacenter.delete()
    end
    
    
    #Racks
    def create_rack(dc, name, vlan_id_min=2, vlan_id_max=4096, nrsq=10)
      rack = org.jclouds.abiquo.domain.infrastructure.Rack.builder(@context, dc) \
      .name(name) \
      .vlanIdMin(vlan_id_min) \
      .vlanIdMax(vlan_id_max) \
      .nrsq(nrsq) \
      .build()
      rack.save()
      rack
    end

    def get_rack(dc, name)
      dc.findRack(RackPredicates.name(name))
    end
    
    def list_racks(dc)
      dc.listRacks()
    end

    def delete_rack(dc, name)
      rack = get_rack(dc, name)
      rack.delete()
    end
    

    #Machines
    def create_machine(rack, type, ip, user, pass, datastore, vswitch)
      datacenter = rack.datacenter
      
      # Discover server info with the Discovery Manager remote service
      machine = datacenter.discoverSingleMachine ip, type, user, pass
      
      # Verify that the desired datastore and virtual switch exist
      datastore = machine.findDatastore datastore 
      vswitch = machine.findAvailableVirtualSwitch vswitch
      
      datastore.setEnabled true
      machine.setVirtualSwitch vswitch
      machine.setRack rack
      
      machine.save()
      machine
    end
    
    def get_machine(rack, ip)
      rack.findMachine(MachinePredicates.ip(ip))
    end
    
    def list_machines(rack = nil)
      return rack.listMachines() if rack

      administration = @context.getAdministrationService()
      administration.listMachines() 
    end
    
    def delete_machine(rack, ip)
      machine = get_machine(rack, ip)
      machine.delete()
    end
    
    
    #Enterprises
    def list_enterprises()
      administration = @context.getAdministrationService()
      administration.listEnterprises() 
    end
  end
end