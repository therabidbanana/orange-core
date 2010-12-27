require 'orange-core/resources/routable_resource'

module Orange
  class ModelResource < RoutableResource
    # Defines a model class as an inheritable class attribute and also an instance
    # attribute
    cattr_accessor :model_class
    attr_accessor :model_class
    # Defines a list of exposed actions
    cattr_accessor :exposed_actions
    cattr_accessor :listable_actions
    # Allows the resource to be nested inside other resources.
    cattr_accessor :nested_in
    # Allows the resource to be nest other resources.
    cattr_accessor :nests
    
    def self.listable(*args)
      self.listable_actions ||= []
      args.each{|arg| self.listable_actions << arg}
    end
    
    # Tells the Model resource which Carton class to scaffold
    # @param [Orange::Carton] my_model_class class name of the carton class to scaffold
    def self.use(my_model_class)
      self.model_class = my_model_class
    end
    
    # Allows the resource to nest other resources
    def self.nests_many(*args)
      self.nests ||= {}
      args.each{|arg| self.nests[arg] = :many}
    end
    
    # Allows the resource to nest other resources
    def self.nests_one(*args)
      self.nests ||= {}
      args.each{|arg| self.nests[arg] = :one}
    end
    
    def nests
      self.class.nests || {}
    end
    
    # Allows the resource to nest inside other resources
    def self.nests_in(*args)
      self.nested_in ||= []
      args.each{|arg| self.nested_in << arg}
    end
    
    def nested_in
      self.class.nested_in
    end
    
    # Overrides the instantiation of new Resource object to set instance model
    # class to the class-level model class defined by #use
    def self.new(*args, &block)
      self.exposed_actions ||= {:all => [:show, :list], :admin => [:all], :orange => [:all]}
      self.listable_actions ||= []
      self.nested_in ||= []
      self.nests ||= {}
      me = super(*args, &block)
      me.model_class = self.model_class 
      me
    end
    
    # Views a packet by calling method defined as opts[:mode].
    # Defaults mode to show or list, if it can't find opts[:mode].
    # Decision between show or list is determined by whether an id has been chosen.
    # An id is set in opts[:id], or extracted from the packet['route.resource_id']. 
    # Calling view is equivalent to calling a viewable method directly, view just
    # sets up safe defaults so method missing errors are less likely.
    # @param [Orange::Packet] packet the packet calling view on this resource
    def view(packet, opts = {})
      resource_id = opts[:id] || packet['route.resource_id', false]
      mode = opts[:mode] || packet['route.resource_action'] || 
        (resource_id ? :show : :index)
      if self.respond_to?(mode)
        self.__send__(mode, packet, opts)
      else
        viewable(packet, mode, opts)
      end
    end
    
    # Allows undefined methods to be viewed with the standard do_view method
    # They must be added to the viewable or listable actions by calling
    # #self.viewable or #self.listable with a set of functions to be viewable
    def viewable(packet, mode, opts={})
      if(self.class.viewable_actions.include?(mode))
        do_view(packet, mode, opts)
      elsif(self.class.listable_actions.include?(mode))
        do_list_view(packet, mode, opts)
      else
        ''
      end
    end
    
    # Renders a view, with all options set for haml to access.
    # Calls #view_opts to generate the haml options. 
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [optional, Array] args the args array
    # @return [String] haml parsed string to be placed in packet[:content] by #route
    def do_view(packet, mode, *args)
      tilt_opts = view_opts(packet, mode, false, *args)
      orange[:parser].tilt(mode.to_s, packet, tilt_opts)
    end
    
    # Renders a view, with all options set for haml to access. Same as do_view, but
    # calls #view_opts with is_list set to true to generate the haml options.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [optional, Array] args the args array
    # @return [String] haml parsed string to be placed in packet[:content] by #route
    def do_list_view(packet, mode, *args)
      tilt_opts = view_opts(packet, mode, true, *args)
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
    def view_opts(packet, mode, is_list, *args)
      opts = args.extract_options!.with_defaults({:path => ''})
      props = model_class.form_props(packet['route.context'], ((is_list || mode == :table_row) ? mode : :any))
      resource_id = opts[:id] || packet['route.resource_id'] || false
      all_opts = {:props => props, :resource => self, :model_name => @my_orange_name}.merge!(opts)
      all_opts.with_defaults! :model => find_one(packet, mode, resource_id) unless is_list
      all_opts.with_defaults! :list => find_list(packet, mode) if is_list
      all_opts.with_defaults! find_extras(packet, mode)
      all_opts
    end
    
    # Returns a single object found by the model class, given an id. 
    # If id isn't given, we return false.
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Object] returns an object of type set by #use, if one found with same id
    def find_one(packet, mode, id = false)
      return false unless id
      model_class.get(id) 
    end
    
    # Returns a list of all objects found by the model class
    # If none, returns an empty array
    # @param [Orange::Packet] packet the packet we are returning a view for
    # @param [Symbol] mode the mode we are trying to view (used to find template name)
    # @param [Numeric] id the id to lookup on the model class
    # @return [Enumerable] returns a collection of objects of type set by #use
    def find_list(packet, mode)
      model_class.all || []
    end
    
    # Creates a new model object and saves it (if a post), then reroutes to the main page
    # @param [Orange::Packet] packet the packet being routed
    def new(packet, opts = {})
      no_reroute = opts.delete(:no_reroute)
      if packet.request.post? || !opts.blank?
        params = opts.with_defaults(opts.delete(:params) || packet.request.params[@my_orange_name.to_s] || {})
        params = params_parse(packet, :new, params)
        before = beforeNew(packet, params)
        obj = onNew(packet, params) if before
        afterNew(packet, obj, params) if before
        obj.save if obj && before
      end
      packet.reroute(@my_orange_name, :orange) unless (packet.request.xhr? || no_reroute)
      obj || false
    end
    
    def params_parse(packet, mode, params)
      props = model_class.form_props(packet['route.context'], :any)
      params.each{|k,v| params[k] = nil if(k.to_s =~ /_id$/ && v.blank?)}
      params
    end
    
    # A callback for the actual new item event
    def onNew(packet, opts = {})
      model_class.new(opts)
    end
    
    # A callback for before a new item is created
    # @param [Orange::Packet] packet the packet being routed
    def beforeNew(packet, opts = {})
      true
    end
    
    # A callback for after a new item is created
    # @param [Orange::Packet] packet the packet being routed
    # @param [Object] obj the model class just created
    def afterNew(packet, obj, opts = {})
    end
    
    # Deletes an object specified by packet['route.resource_id'], then reroutes to main.
    # The request must come in as a delete. Rack::MethodOverride can be used to do this.
    # @param [Orange::Packet] packet the packet being routed
    def delete(packet, opts = {})
      no_reroute = opts.delete(:no_reroute)
      if packet.request.delete? || !opts.blank?
        id = opts.delete(:resource_id) || packet['route.resource_id']
        m = opts.delete(:model) || model_class.get(id)
        before = beforeDelete(packet, m, opts)
        onDelete(packet, m, opts) if m && before
        afterDelete(packet, m, opts) if before
        orange.fire(:model_resource_deleted, packet, {:resource_id => id, :resource => @my_orange_name})
      end
      packet.reroute(@my_orange_name, :orange) unless (packet.request.xhr? || no_reroute)
    end
    
    def beforeDelete(packet, obj, opts = {})
      true
    end
    
    # Delete object
    def onDelete(packet, obj, opts = {})
      obj.destroy
    end
    
    def afterDelete(packet, obj, opts = {})
    end
    
    # Saves updates to an object specified by packet['route.resource_id'], then reroutes to main
    # @param [Orange::Packet] packet the packet being routed
    def save(packet, opts = {})
      no_reroute = opts.delete(:no_reroute)
      if packet.request.post? || !opts.blank?
        my_id = opts.delete(:resource_id) || packet['route.resource_id']
        m = opts.delete(:model) || model_class.get(my_id)
        params = opts.with_defaults(opts.delete(:params) || packet.request.params[@my_orange_name.to_s] || {})
        params = params_parse(packet, :save, params)
        if m
          before = beforeSave(packet, m, params)
          onSave(packet, m, params) if before
          afterSave(packet, m, params) if before
        end
      end
      packet.reroute(@my_orange_name, :orange) unless (packet.request.xhr? || no_reroute)
      m || false
    end
    
    def beforeSave(packet, obj, opts = {})
      true
    end
    
    def onSave(packet, obj, opts = {})
      obj.update(opts)
    end
    
    def afterSave(packet, obj, opts = {})
    end
    
    # Calls #do_view with :show mode
    # @param [Orange::Packet] packet the packet being routed
    def show(packet, *opts)
      do_view(packet, :show, *opts)
    end
    
    # Calls #do_view with :edit mode
    # @param [Orange::Packet] packet the packet being routed
    def edit(packet, *opts)
      do_view(packet, :edit, *opts)
    end
    
    # Calls #do_view with :create mode
    # @param [Orange::Packet] packet the packet being routed
    def create(packet, *opts)
      do_view(packet, :create, *opts)
    end
    
    # Calls #do_view with :table_row mode
    # @param [Orange::Packet] packet the packet being routed
    def table_row(packet, *opts)
      do_view(packet, :table_row, *opts)
    end
    
    # Calls #do_list_view with :list mode
    # @param [Orange::Packet] packet the packet being routed
    def list(packet, *opts)
      do_list_view(packet, :list, *opts)
    end
    
    # Calls #do_list_view with :list mode. 
    # @param [Orange::Packet] packet the packet being routed
    def index(packet, *opts)
      do_list_view(packet, :list, *opts)
    end
    
    # Add methods to the list of exposed actions. 
    def self.expose(*args)
      self.exposed_actions ||= {:all => [:show, :list], :admin => :all, :orange => :all}
      self.exposed_actions.merge!(args.extract_options!)
      self.exposed_actions[:all].concat(args)
    end
    
    # Add an exclusive list of exposed actions. List is cleared out beforehand
    def self.expose_only(*args)
      self.exposed_actions = {:all => []}
      self.exposed_actions.merge!(args.extract_options!)
      self.exposed_actions[:all].concat(args)
    end
    
    # Exposed method for helping the RestfulRouter class.
    def exposed(packet)
      self.class.exposed_actions ||= {:all => [:show, :list], :admin => :all, :orange => :all}
      all = self.class.exposed_actions[:all]
      all = [all] unless all.is_a?(Array)
      context = self.class.exposed_actions[packet['route.context']]
      context = [context] unless context.is_a?(Array)
      all+context
    end
  
  end
  
end