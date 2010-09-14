require 'orange-core/core'

module Orange
  class Mapper < Resource
    # Takes a packet extracts request information, then calls packet.route
    def afterLoad
      orange.add_pulp Pulp::Packet_Mapper
    end
    
    def root_url(packet)
      root = ''
      root += packet['route.root_dir'].gsub(/\/$/,'') if packet['route.root_dir']
      root += '/'
    end
    
    def route_to(packet, resource, *args)
      opts = args.extract_options!
      packet = DefaultHash.new unless packet 
      context = opts[:context]
      context = packet['route.context', nil] unless (context || (packet['route.context'] == :live))
      site = packet['route.faked_site'] ? packet['route.site_url', nil] : nil
      args.unshift(resource)
      args.unshift(context)
      args.unshift(site)
      root_url(packet) + args.compact.join('/')
    end
  end
  
  module Pulp::Packet_Mapper
    def route_to(resource, *args)
      if resource.respond_to?(:full_path)
        orange[:mapper].root_url(packet) + resource.full_path.gsub(/^\//,'')
      else
        orange[:mapper].route_to(self, resource, *args)
      end
    end
    
    def root_url
      orange[:mapper].root_url(packet)
    end
    
    def full_url(*args)
      orange[:mapper].root_url(packet) + args.compact.join('/')
    end
    
    def reroute(url, type = :real, *args)
      packet['reroute.to'] = url
      packet['reroute.type'] = type
      packet['reroute.args'] = *args if args
      raise Reroute.new(self), 'Unhandled reroute'
    end
  end
  
end