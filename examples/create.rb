require File.join(File.dirname(__FILE__), '../lib/haki')

MACHINE_IP = 'HYPERVISOR_IP'
ENDPOINT_IP = 'API_IP'
ENDPOINT_USER = 'admin'
ENDPOINT_PASS = 'xabiquo'


include Haki
context = Haki.create_context "http://#{ENDPOINT_IP}/api", ENDPOINT_USER, ENDPOINT_PASS

ent = context.getAdministrationService().getEnterprise(1)

infra = Haki::InfrastructureController.new context
cloud = Haki::CloudController.new context

#Create DC
dc = infra.create_dc 'haki', 'bcn', ENDPOINT_IP
puts "DC created"

#Create Rack
rack = infra.create_rack dc, 'haki_rack'
puts "Rack created"

#Create Machine
machine = infra.create_machine rack, HypervisorType::VMX_04, MACHINE_IP, 'root', 'temporal0!', 'sharedvmfs', 'vSwitch1'
puts "Machine created"

#Create VDC
vdc = cloud.create_virtual_datacenter(dc, ent, HypervisorType::VMX_04, 'haki_vdc', 'default', '192.168.0.0', 24, '192.168.0.1')
puts "VDC created"

#Create vApp
vapp = cloud.create_virtual_appliance(vdc, 'haki_vapp')
puts "vApp created"

#Get template m0n0wall
cloud.refresh_template_repository(ent, dc)
t = cloud.find_template(vdc, 'm0n0wall')
puts "Template selected"

#Create VirtualMachine
vm = cloud.create_virtual_machine(vapp, t)
puts "VM created"

#Deploy!
monitor = context.getMonitoringService().getVirtualApplianceMonitor()
puts "Deploying..."
vapp.deploy()
monitor.awaitCompletionUndeploy(vapp)

puts "Done!"

context.close

