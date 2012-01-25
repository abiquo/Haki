import org.jclouds.abiquo.domain.infrastructure.Datacenter
import org.jclouds.abiquo.domain.infrastructure.Rack
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
    
    def delete_dc(name)
      datacenter = get_dc(name)
      datacenter.delete()
    end
    
    def create_rack(dc, name, vlan_id_min=2, vlan_id_max=4096, nrsq=10)
      rack = Rack.builder(@context, dc) \
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

    def delete_rack(dc, name)
      rack = get_rack(dc, name)
      rack.delete()
    end
    
    
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
    
    def delete_machine(rack, ip)
      machine = get_machine(rack, ip)
      machine.delete()
    end
  end
end