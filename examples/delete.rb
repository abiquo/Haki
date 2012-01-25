require File.join(File.dirname(__FILE__), '../lib/haki')

DC_NAME = 'haki'
ENTERPRISE_ID = 1


include Haki
context = Haki.create_context 'http://10.60.20.214/api', 'admin', 'xabiquo'

ent = context.getAdministrationService().getEnterprise(ENTERPRISE_ID)

infra = Haki::InfrastructureController.new context
cloud = Haki::CloudController.new context

dc = infra.get_dc(DC_NAME)
ent = context.getAdministrationService().getEnterprise(ENTERPRISE_ID)
vdc = cloud.get_virtual_datacenter('haki_vdc')
vapp = cloud.get_virtual_appliance('haki_vapp')

monitor = context.getMonitoringService().getVirtualApplianceMonitor()

vapp.undeploy()
monitor.awaitCompletionUndeploy(vapp)

vapp.delete()
puts "VAPP deleted"
vdc.delete()
puts "VDC deleted"

infra.delete_dc DC_NAME
puts "DC deleted"

context.close

