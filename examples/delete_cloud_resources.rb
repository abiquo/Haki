require File.join(File.dirname(__FILE__), '../lib/haki')

ENDPOINT_IP = 'IP'
ENDPOINT_USER = 'USER'
ENDPOINT_PASS = 'PASSWORD'

include Haki

puts "Create context"
context = Haki.create_context "http://#{ENDPOINT_IP}/api", ENDPOINT_USER, ENDPOINT_PASS

cloud = Haki::CloudController.new context

vdcs = cloud.list_virtual_datacenters()
vapps = cloud.list_virtual_appliances()

monitor = context.getMonitoringService().getVirtualApplianceMonitor()

puts "Undeploy..."
puts vapps
vapps.each {|vapp| puts "NULL" unless vapp; vapp.undeploy()}

vapps.each do |vapp|
  monitor.awaitCompletionUndeploy(vapp)
  puts "Undeployed and deleting #{vapp.name}"
  vapp.delete()
end

vdcs.each do |vdc|
  puts "Delete #{vdc.name}"
  vdc.delete()
end

context.close

