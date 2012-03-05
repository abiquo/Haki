require 'json-schema'

module ApiDataChecks
  def check_test_data data
    test_schema = {
      "type" => "object",
      "properties" => {
        "endpoint" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "ip" => {"type" => "string", "required" => true},
            "user" => {"type" => "string", "required" => true},
            "password" => {"type" => "string", "required" => true}
          }
        },
        "test" => {
          "type" => "object",
          "required" => true,
          "properties" => {
            "hypervisor" => {"type" => "string", "required" => false},
            "vdcs" => {"type" => "string", "required" => true},
            "vapps" => {"type" => "string", "required" => true},
            "vms" => {"type" => "string", "required" => true},
            "template" => {"type" => "string", "required" => false}
          }
        }
      }  
    }

    JSON::Validator.validate!(test_schema, data)
    
  end
end
