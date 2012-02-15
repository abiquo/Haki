require File.join(File.dirname(__FILE__), '../lib/haki')
require 'pp'

ENDPOINT_IP = 'IP'
ENDPOINT_USER = 'USER'
ENDPOINT_PASS = 'PASSWORD'

include Haki

cloud_test = Haki::CloudTest.new :endpoint_ip => ENDPOINT_IP,
  :user => ENDPOINT_USER,
  :pass => ENDPOINT_PASS,
  :hyp_type => HypervisorType::VMX_04,
  :num_vdcs => 1,
  :num_vapps => 2,
  :num_vms => 2,
  :template => 'm0n0wall'
  
puts "Create test env"
cloud_test.create
pp cloud_test.status

puts "Deploy"
cloud_test.deploy
cloud_test.await_end_deploy
pp cloud_test.status

puts "Undeploy"
cloud_test.undeploy
cloud_test.await_end_undeploy
pp cloud_test.status

puts "Delete"
cloud_test.destroy
pp cloud_test.status

cloud_test.context.close