require File.join(File.dirname(__FILE__), '../lib/haki')
require 'pp'

ENDPOINT_IP = 'IP'
ENDPOINT_USER = 'USER'
ENDPOINT_PASS = 'PASSWORD'

include Haki

test = {"endpoint" => {
    "ip" => ENDPOINT_IP,
    "user" => ENDPOINT_USER,
    "password" => ENDPOINT_PASS
  },
    "test" => {
      #"hypervisor" => "kvm",
      #"template" => "Core",
      "vdcs" => "1",
      "vapps" => "10",
      "vms" => "2"
  }
}

cloud_test = Haki::CloudTest.new test
  

for i in 1..10 do
  puts "ITERACIO #{i}"
  puts "Create test env"
  cloud_test.create
  
  puts "Deploy all"
  #10 retries
  for i in 1..10 do
    cloud_test.deploy
    cloud_test.await_end_deploy
    
    deployed = true
    cloud_test.status[:vms].each {|k,v| deployed = false if v != 'ON'}
    break if deployed
    puts "Failed! Retry..."
  end
  
  puts "Undeploy all"
  #10 retries
  for i in 1..10 do
    cloud_test.undeploy
    cloud_test.await_end_undeploy

    undeployed = true
    cloud_test.status[:vms].each {|k,v| undeployed = false if v != 'NOT_ALLOCATED'}
    break if undeployed
    puts "Failed! Retry..."
  end
  
  puts "Delete all"
  cloud_test.destroy
end

cloud_test.context.close