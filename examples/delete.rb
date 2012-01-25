require File.join(File.dirname(__FILE__), '../lib/haki')

ENDPOINT_IP = 'API_IP'
ENDPOINT_USER = 'admin'
ENDPOINT_PASS = 'xabiquo'


include Haki
context = Haki.create_context "http://#{ENDPOINT_IP}/api", ENDPOINT_USER, ENDPOINT_PASS

ent = context.getAdministrationService().getEnterprise(1)

infra = Haki::InfrastructureController.new context
cloud = Haki::CloudController.new context

vdc = cloud.get_virtual_datacenter('haki_vdc')
vapp = cloud.get_virtual_appliance('haki_vapp')

monitor = context.getMonitoringService().getVirtualApplianceMonitor()

puts "Undeploy..."
vapp.undeploy()
monitor.awaitCompletionUndeploy(vapp)

vapp.delete()
puts "VAPP deleted"
vdc.delete()
puts "VDC deleted"

infra.delete_dc 'haki'
puts "DC deleted"

context.close

