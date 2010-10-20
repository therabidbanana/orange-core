require 'tilt'

module Orange
  # Orange::Packet is a wrapper for Rack's basic env variable. 
  # It acts somewhat like Rack::Request, except with more functionality.
  # For each request a unique Packet is generated, and this packet is 
  # used to by middleware to create the response. 
  # 
  # All orange enhanced middleware has a packet_call method that
  # automatically turns the generic rack call(env) into a call
  # that has a packet instead, so all functions for the packet should
  # be available for the request.
  #
  # Pulps are modules that are mixed into the Packet, allowing
  # additional functionality to be used by the packet.
  #
  # By default, haml files are parsed in the context of their
  # packet. This means all of instance variables and functions should
  # be available to the haml parser.
  class Packet
    # By default, header will be content-type
    DEFAULT_HEADERS = {"Content-Type" => 'text/html'} unless defined?(DEFAULT_HEADERS)
    
    # Tilt support
    include Tilt::CompileSite
    
    # We override the instantiation to only create one packet per env
    # @param [Orange::Core] orange a pointer to the orange core
    # @param [Hash] env a standard Rack hash
    def self.new(orange, env)
      return env['orange.packet'] if env['orange.packet']
      super(orange, env)
    end
    
    # Allows tying in to the method_missing method without redefining it 
    # elsewhere. This lets dynamic methods be defined on the packet.
    # Regexes are defined to match method names. #method_missing will
    # loop through and try to find a match, executing the proc defined in
    # the block.
    # @param [Regexp] regex the regex to match
    # @yield [Orange::Packet, MatchData, args] the block to execute if matched 
    #   (passed instance, match data and args)
    def self.meta_methods(regex, &block)
      return unless block_given?
      proc = block
      @@matchers ||= {}
      @@matchers[regex] = proc
    end
    
    # Allows access to the matchers added via the #meta_methods method
    # @return [Hash] the matchers hash
    def matchers
      @@matchers || {}
    end
    
    # Initialize is only called if a packet hasn't already been called for 
    # this env. Sets up the basic env, creating a pointer back to self
    # and a Rack::Request object.
    # @param [Orange::Core] orange a pointer to the orange core
    # @param [Hash] env a standard Rack hash
    def initialize(orange, env)
      @orange = orange
      @env = env
      @env['orange.packet'] = self
      @env['orange.env'] = {} unless @env['orange.env']
      @env['orange.env'][:request] = Rack::Request.new(env)
      @env['orange.env'][:headers] = {}
    end
    
    # Gives access to the orange.env key in the env, optionally 
    # including a default if key isn't involved.
    # @param [Symbol, String] key the key to be found
    # @param [optional, Object] default the return value if key doesn't exist (default is false)
    # @return [Object] any value stored in the env
    def [](key, default = false)
      @env['orange.env'].has_key?(key) ? @env['orange.env'][key] : default
    end
    
    # Lets user set a value in the orange.env
    # @param [Symbol, String] key the key to be set
    # @param [Object] val the value to be set
    def []=(key, val)
      @env['orange.env'][key] = val
    end
    
    # Access to the main env (orange env is stored within the main env)
    # @return [Hash] the request's env hash
    def env
      @env
    end
    
    # Access to the rack session
    # @return [Hash] the session information made available by Rack
    def session
      env['rack.session']["flash"] ||= {}
      env['rack.session']
    end
    
    # Access to the rack session flash
    # @return [String] the string stored in the flash
    def flash(key = nil, val = nil)
      env['rack.session']["flash"] ||= {}
      if key.nil? && val.nil?
        env['rack.session']["flash"]
      elsif val.nil?
        env['rack.session']["flash"].delete(key)
      else
        env['rack.session']["flash"][key] = val
      end
    end 
    
    # Generate headers for finalization
    # @return [Hash] the header information stored in the orange.env, combined with the defaults
    #   set as DEFAULT_HEADERS
    def headers
      packet[:headers, {}].with_defaults(DEFAULT_HEADERS)
    end
    
    # Set a header
    # @param [String] key the key to be set
    # @param [Object] val the value to be set
    def header(key, val)
      @env['orange.env'][:headers][key] = val
    end
    
    # Set a header (same as #header)
    # @param [String] key the key to be set
    # @param [Object] val the value to be set
    def add_header(key, val)
      header key, val
    end
    
    # Returns the content ready to be used by Rack (wrapped in an array)
    # @return [Array] array of strings to be rendered
    def content
      # Stringify content if it isn't a string for some weird reason.
      packet[:content] = packet[:content].to_s unless packet[:content].is_a? String
      return [packet[:content]] if packet[:content]
      return ['']
    end
    
    # Returns the request object generated by Rack::Request(packet.env)
    # @return [Rack::Request] the request object
    def request
      packet[:request]
    end
    
    # A pointer to the Orange::Core instance
    # @return [Orange::Core] the orange core run by the application
    def orange
      @orange
    end
    
    # Returns the array of [status, headers, content] Rack expects
    # @return [Array] the triple array expected by Rack at the end 
    #   of a call
    def finish
      headers = packet.headers
      status = packet[:status, 200]
      content = packet.content
      if content.respond_to?(:to_ary)
        headers["Content-Length"] = content.to_ary.
          inject(0) { |len, part| len + Rack::Utils.bytesize(part) }.to_s
      end
      [status, headers, content]
    end
    
    # Returns self
    # @return [Orange::Packet] self
    def packet
      self
    end
    
    # Includes the module passed
    # @param [Module] inc the module to be mixed into the class
    def self.mixin(inc)
      include inc
    end
    
    # Route calls the router object set in the packet
    # @return [void] route doesn't return anything directly, the
    #   main application calls packet.route then returns packet.finish.
    #   Routers set content, headers and status if necessary.
    #   They can also raise redirect errors to circumvent the process.
    def route
      router = packet['route.router']
      raise 'Router not found' unless router
      router.route(self)
    end
    
    # Pulls options set out of the packet and places them into
    # a hash. Options are retrieved from POST, GET, and route.resource_path
    # and take that order of precedence (POST overrides GET, etc)
    # @param [Array] key_list an array of keys to retrieve and merge together
    #   in order of precedence. :GET and :POST for request vars, the rest
    #   are keys directly available on packet
    # @return [Hash] A hash of options set in the packet
    def extract_opts(key_list = [:POST, :GET, 'route.resource_path'])
      opts = {}
      key_list.reverse.each do |key|
        case key
        when :GET then opts.merge! packet.request.GET
        when :POST then opts.merge! packet.request.POST
        else 
          opts.merge!(packet[key, {}].kind_of?(String) ? url_to_hash(packet[key]) : packet[key, {}])
        end
      end
      opts
    end
    
    # Converts a url path to a hash with symbol keys. URL must
    # be in /key/val/key/val/etc format
    def url_to_hash(url)
      parts = url.split('/')
      hash = {}
      while !parts.blank?
        key = parts.shift
        key = parts.shift if key.blank?
        val = parts.shift
        hash[key.to_sym] = val unless key.blank? or val.blank?
      end
      hash
    end
    
    # Method Missing allows defining custom methods
    def method_missing(id, *args)
      matched = false
      id = id.to_s
      @@matchers.each_key do |k|
        matched = k if id =~ k
        break if matched
      end
      return @@matchers[matched].call(packet, matched.match(id), args) if matched
      raise NoMethodError.new("No method ##{id} found", id)
    end
  end
end