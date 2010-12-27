require 'orange-core/core'

module Orange
  # Orange Resource for being subclassed
  class Resource
    extend ClassInheritableAttributes
    # Defines a model class as an inheritable class attribute and also an instance
    # attribute
    cattr_accessor :called
    cattr_accessor :viewable_actions
    
    def nests
      {}
    end
    
    def self.viewable(*args)
      self.viewable_actions ||= []
      args.each{|arg| self.viewable_actions << arg}
    end
    
    def initialize(*args, &block)
      @options = DefaultHash.new.merge!(Options.new(*args, &block).hash)
      self.class.viewable_actions ||= []
    end
    
    def set_orange(orange, name)
      @orange = orange
      @my_orange_name = name
      init
      orange.register(:stack_loaded) { |s| stack_init } if self.respond_to? :stack_init
      self
    end
    
    def self.set_orange(*args)
      raise 'instantiate the resource before calling set orange'
    end
    
    def init
      afterLoad
    end
    
    def afterLoad
    end
    
    def self.call_me(name)
      self.called = name
    end
    
    def orange
      @orange
    end
    
    def routable
      false
    end
    
    def view(packet = false, *args)
      opts = args.extract_options!
      my_action = packet['route.resource_action'] if packet
      action = opts[:mode] || opts[:resource_action] || my_action || :index
      viewable(packet, action, opts)
    end
    
    def viewable(packet, mode, opts={})
      self.class.viewable_actions ||= []
      if(self.respond_to?(mode))
        self.__send__(mode, packet, opts)
      elsif(self.class.viewable_actions.include?(mode))
        do_view(packet, mode, opts)
      else
        ''
      end
    end
    
    def orange_name
      @my_orange_name || self.class.called || false
    end
    
    def options
      @options 
    end
    
    # Renders a view, with all options set for haml to access.
    # Calls #view_opts to generate the haml options. 
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [optional, Array] args the args array
    # @return [String] haml parsed string to be placed in packet[:content] by #route
    def do_view(packet, mode, *args)
      tilt_opts = view_opts(packet, mode, *args)
      orange[:parser].tilt(mode.to_s, packet, tilt_opts)
    end
    
    
    # Returns the options for including in template rendering. All keys passed in the args array
    # will automatically be local variables in the haml template.
    # In addition, the props, resource, and model_name variables will be available.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [boolean] is_list whether we want a list or not (view_opts will automatically look up
    #   a single object or a list of objects, so we need to know which)
    # @param [optional, Array] args the args array
    # @return [Hash] hash of options to be used
    def view_opts(packet, mode, *args)
      opts = args.extract_options!.with_defaults({:path => ''})
      all_opts = {:resource => self, :model_name => @my_orange_name}.merge!(opts)
      all_opts.with_defaults! find_extras(packet, mode)
      all_opts
    end
    
    # Returns a hash of extra options to be set and made available by the haml parser.
    # Overriding this method is useful for passing extra bits of info to rendering
    # for certain view modes without rewriting all of the other scaffolding
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @return [Hash] a hash of extras to be included in the rendering
    def find_extras(packet, mode)
      {}
    end
  end
end