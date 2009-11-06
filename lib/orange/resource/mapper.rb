require 'orange/core'

module Orange
  class Mapper < Resource
    # Takes a packet extracts request information, then calls packet.route
    def afterLoad
      orange.add_pulp Pulp::Packet_Mapper
    end
    
    def template(packet)
      if packet['route.context'] == :admin
        packet.add_css('admin.css', :module => '_orange_')
        packet.add_js('admin.js', :module => '_orange_')
        orange.fire(:view_admin, packet)
        return 'admin.haml'
      else 
        return false
      end
    end
    
    def route_to(packet, resource, *args)
      context = packet['route.context', nil]
      site = packet['route.faked_site'] ? packet['route.site_url', nil] : nil
      args.unshift(resource)
      args.unshift(context)
      args.unshift(site)
      '/'+args.compact.join('/')
    end
  end
  
  module Pulp::Packet_Mapper
    def route_to(resource, *args)
      orange[:mapper].route_to(self, resource, *args)
    end
    
    def reroute(url, type = :real)
      packet['reroute.to'] = url
      packet['reroute.type'] = type
      raise Reroute.new(self), 'Unhandled reroute'
    end
    
  end
  
  class Reroute < Exception
    def initialize(packet)
      @packet = packet
      @packet[:headers] = {"Content-Type" => 'text/html', "Location" => self.url}
      @packet[:status] = 302
    end
    
    def url
      case packet['reroute.type']
      when :real
        packet['reroute.to']
      # Parsing for orange urls or something
      when :orange
        packet.route_to(packet['reroute.to'])
      end
    end
    
    def packet
      @packet
    end
  end
  
end