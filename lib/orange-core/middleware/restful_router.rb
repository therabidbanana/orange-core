require 'orange-core/middleware/base'

module Orange::Middleware
  class RestfulRouter < Base
    def init(*args)
      opts = args.extract_options!.with_defaults(:restful_contexts => [:admin, :orange], :not_found => false, :exposed_actions => {:admin => :all, :orange => :all})
      @exposed = opts[:exposed_actions]
      @contexts = opts[:restful_contexts]
      @not_found = opts[:not_found]
    end
    
    # sets resource, resource_id, resource_action and resource_path
    # /resource/id/action/[resource/path/if/any]
    # /resource/action/[resource/path/if/any]
    # 
    # In future - support for nested resources
    def packet_call(packet)
      return (pass packet) if packet['route.router']  # Don't route if other middleware
                                                      # already has
      parts = route_parts(packet)
      if(should_route?(packet, parts))
        # Take parts of route and set packet info
        first_part = parts.pop
        
        packet['route.resource'] = first_part[:resource] if first_part[:resource]
        packet['route.resource_id'] = first_part[:resource_id] if first_part[:resource_id]
        packet['route.resource_action'] = first_part[:resource_action] if first_part[:resource_action]
        
        # Take remainder and set to resource_path
        packet['route.resource_path'] = first_part[:remainder] if first_part[:remainder]
        packet['route.nesting'] = parts
        # Set self as router if resource was found
        if(packet['route.resource', false]) 
          packet['route.router'] = self
        elsif(@not_found)
          packet['route.resource'] = @not_found
          packet['route.router'] = self
        end
      end 
      
      pass packet
    end
    
    def get_parts(path, nested_in = nil)
      return_parts = {}
      parts = path.split('/')
      pad = parts.shift
      if !parts.empty?
        resource = parts.shift
        if orange.loaded?(resource.to_sym) && (!nested_in || orange[nested_in, true].nests.keys.include?(resource.to_sym))
          return_parts[:resource] = resource.to_sym
          if !parts.empty?
            second = parts.shift
            if second =~ /^\d+$/
              return_parts[:resource_id] = second
              if !(parts.empty? || orange[resource.to_sym, true].nests.keys.include?(parts.first.to_sym))
                return_parts[:resource_action] = parts.shift.to_sym
              else
                return_parts[:resource_action] = :show
              end
            elsif orange[resource.to_sym].nests.keys.include?(second.to_sym)
              # we're nesting if the action is the same as a resource name
              return_parts[:resource_action] = :show
            else
              return_parts[:resource_action] = second.to_sym
            end 
          else
            return_parts[:resource_action] = :list
          end # end check for second part
        else
          parts.unshift(resource)
        end # end check for loaded resource
      end # end check for nonempty route
      return_parts[:remainder] = parts.unshift(pad).join('/')
      return_parts
    end
    
    def route_parts(packet)
      path = packet['route.path'] || packet.request.path_info
      my_parts = []
      my_parts << get_parts(path)
      new_path = my_parts.last[:remainder]
      nested = my_parts.last[:resource]
      until (new_path.blank? || new_path == "/" )
        parts = get_parts(new_path, nested)
        break if new_path == parts[:remainder]
        my_parts << parts
        new_path = parts[:remainder]
        nested = my_parts.last[:resource]
      end
      packet['route.route_parts'] = my_parts
    end
    
    def should_route?(packet, parts)
      return false unless @exposed.has_key?(packet['route.context'])
      if parts.first[:resource].blank? || !(orange[parts.first[:resource]].respond_to?(:exposed))
        action_exposed?(@exposed[packet['route.context']], parts.first)   
      else
        # This allows ModelResources to expose their own action.
        # (Other resources too, but those ones have to explicitly define
        # the #exposed(packet) method to work)
        new_parts = parts.first.dup
        new_parts.delete(:resource)
        action_exposed?(orange[parts.first[:resource]].exposed(packet), new_parts)
      end
    end
    
    def action_exposed?(list, route_parts)
      return true if list == :all
      return true if list == route_parts[:resource_action]
      return true if list.is_a?(Array) && (list.include?(route_parts[:resource_action]) || list.include?(:all))
      if list.is_a?(Hash)
        all = list.has_key?(:all) ? action_exposed?(list[:all], route_parts) : false
        one = list.has_key?(route_parts[:resource]) ? action_exposed?(list[route_parts[:resource]], route_parts) : false
        return all || one
      end
      false
    end
    
    def route(packet)
      resource = packet['route.resource']
      raise 'resource not found' unless orange.loaded? resource
      mode = packet['route.resource_action'] || 
        (packet['route.resource_id'] ? :show : :list)
      packet[:content] = orange[resource].view packet
    end
  end
end