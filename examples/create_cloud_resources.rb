require File.join(File.dirname(__FILE__), '../lib/haki')

ENDPOINT_IP = 'IP'
ENDPOINT_USER = 'USER'
ENDPOINT_PASS = 'PASSWORD'

include Haki

puts "Create context"
context = Haki.create_context "http://#{ENDPOINT_IP}/api", ENDPOINT_USER, ENDPOINT_PASS

puts "Create VDCs"
vdcs = Haki::create_vdcs context, 1, HypervisorType::VMX_04

puts "Create VAPPs"
vapps = Haki::create_vapps context, 2, vdcs

puts "Create nodes and deploy"
vapps.each do |vapp|
  vms = Haki::create_nodes context, 5, vapp, 'm0n0wall'
  vapp.deploy
end

monitor = context.getMonitoringService().getVirtualApplianceMonitor()

vapps.each do |vapp|
  monitor.awaitCompletionDeploy(vapp)
  puts "Deployed #{vapp.name}"
end

puts "Done!"

context.close