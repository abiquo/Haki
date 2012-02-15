require 'java'

#Load jcloud-abiquo and all deps
IO.foreach(File.join(File.dirname(__FILE__), '../deps'),':') do |dep|
  require dep.delete ':'
end


#Required properties for jclouds
import java.lang.System
import com.abiquo.model.enumerator.HypervisorType
import java.util.Properties
import org.jclouds.abiquo.AbiquoContextFactory

context_builder="org.jclouds.abiquo.AbiquoContextBuilder"
props_builder="org.jclouds.abiquo.AbiquoPropertiesBuilder"
System.setProperty("abiquo.contextbuilder", context_builder)
System.setProperty("abiquo.propertiesbuilder", props_builder)

require File.expand_path(File.join(File.dirname(__FILE__), 'controllers/infrastructure_controller'))
require File.expand_path(File.join(File.dirname(__FILE__), 'controllers/cloud_controller'))
require File.expand_path(File.join(File.dirname(__FILE__), 'tester/test_launcher'))
require File.expand_path(File.join(File.dirname(__FILE__), 'tester/cloud_tester'))


module Haki  
  def create_context(endpoint, user, password)
      config = Properties.new
      config.put("abiquo.endpoint", endpoint)
      AbiquoContextFactory.new.createContext(user, password, config)
  end
end