
require_relative "../../../lib/haki"

include Haki
include ApiDataChecks

class TestsApp < Sinatra::Base

  @@tests = Hash.new

  get "/tests" do
    puts "Tests: #{@tests}"
    content_type :json
    return @@tests.to_json
  end


  post "/tests" do
    # expected data:
    # test={
    #   "endpoint" : {
    #     "ip" : "10.60.20.213",
    #     "user" : "admin",
    #     "password" : "xabiquo"
    #   },
    #   "test" : {
    #     "hypervisor" : "esxi",
    #     "vdcs" : "1",
    #     "vapps" : "1",
    #     "vms" : "2",
    #     "template" : "m0n0wall"
    #   }
    # }

    @@tests ||= Hash.new

    begin
      data = JSON.parse request.POST['test']

      ApiDataChecks.check_test_data data

      key = UUID.generate
      @@tests[key] = data

      cloud_test = Haki::CloudTest.new @@tests[key]
      cloud_test.create

      content_type :json
      
      return {:id => key}.to_json
    rescue Exception => e
      raise e
    end
  end

  post "/tests/:id/deploy" do
    # expected data:
    # {}
    raise Sinatra::NotFound unless @@tests[params[:id]]

    begin
      cloud_test = Haki::CloudTest.new @@tests[params[:id]]
      cloud_test.deploy

      return
    rescue Exception => e
      raise e
    end
  end


  get "/tests/:id/status" do

    raise Sinatra::NotFound unless @@tests[params[:id]]

    begin
      cloud_test = Haki::CloudTest.new @@tests[params[:id]]
      
      content_type :json
      
      return cloud_test.status.to_json
    rescue Exception => e
      raise e
    end
  end

  post "/tests/:id/undeploy" do
    # expected data:
    # {}
    raise Sinatra::NotFound unless @@tests[params[:id]]

    begin
      cloud_test = Haki::CloudTest.new @@tests[params[:id]]
      cloud_test.undeploy

      return
    rescue Exception => e
      raise e
    end
  end

  delete "/tests/:id" do
    # expected data:
    # {}
    raise Sinatra::NotFound unless @@tests[params[:id]]

    begin
      cloud_test = Haki::CloudTest.new @@tests[params[:id]]
      cloud_test.destroy

      @@tests.delete params[:id]

      return
    rescue Exception => e
      raise e
    end
  end

end