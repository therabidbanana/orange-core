require 'orange-core/core'
require 'haml'
require 'yaml'
require 'crack'

module Orange
  class Parser < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::ParserPulp
      @template_dirs = [File.join(orange.core_dir, 'templates')]
      @view_dirs = [File.join(orange.core_dir, 'views')]
      orange.plugins.each{|p| @template_dirs << p.templates if p.has_templates? }
      orange.plugins.each{|p| @view_dirs << p.views if p.has_views? }
    end
    
    def yaml(file)
      return nil unless File.exists?(file)
      string = File.read(file) 
      string.gsub!('__ORANGE__', orange.app_dir)
      out = YAML::load(string)
    end
    
    def haml(file, packet_binding, *vars, &block)
      
      opts = vars.extract_options!
      # Initial info
      temp = opts.delete(:template)
      opts[:resource_name] = opts[:resource].orange_name.to_s if 
          opts[:resource] && opts[:resource].respond_to?(:orange_name)
      resource = (opts[:resource_name] || '').downcase
      
      opts.merge :orange => orange
      if packet_binding.is_a? Orange::Packet
        context = packet_binding['route.context'].to_s
      end
        
      string = false
      string ||= read_if_exists(file)
      
      if temp
        string ||= read_if_exists('templates', file) 
        @template_dirs.reverse_each do |templates_dir|
          string ||= read_if_exists(templates_dir, file)
        end unless string
      end
      
      if context
        #Check for context specific overrides
        string ||= read_if_exists('views', resource, context+"."+file) if resource
        string ||= read_if_exists('views', context+"."+file) unless resource
        @view_dirs.reverse_each do |views_dir|
          string ||= read_if_exists(views_dir, resource, context+"."+file) if resource
          string ||= read_if_exists(views_dir, context+"."+file) unless resource
        end unless string
      end
    
      # Check for standard views
      string ||= read_if_exists('views', resource, file) if resource
      string ||= read_if_exists('views', file) unless resource
      @view_dirs.reverse_each do |views_dir|
        string ||= read_if_exists(views_dir, resource, file) if resource
        string ||= read_if_exists(views_dir, file) unless resource
      end unless string
    
      # Check for default resource views
      string ||= read_if_exists('views', 'default_resource', context+"."+file) if context
      string ||= read_if_exists('views', 'default_resource', file)
      @view_dirs.reverse_each do |views_dir|
        string ||= read_if_exists(views_dir, 'default_resource', context+"."+file) if context
        string ||= read_if_exists(views_dir, 'default_resource', file)
      end unless string
      raise LoadError, "Couldn't find haml file '#{file}'" unless string
      
      haml_engine = Haml::Engine.new(string)
      opts[:opts] = opts.dup
      out = haml_engine.render(packet_binding, opts, &block)
    end
    
    def read_if_exists(*args)
      return File.read(File.join(*args)) if File.exists?(File.join(*args))
      false
    end
    
    def hpricot(text)
      require 'hpricot'
      Hpricot(text)
    end
    
    def xml(text)
      Crack::XML.parse(text)
    end
    
    def json(text)
      Crack::JSON.parse(text)
    end
  end 
  
  module Pulp::ParserPulp
    def html(&block)
      if block_given?
        unless(packet[:content].blank?)
          doc = orange[:parser].hpricot(packet[:content])
          yield doc
          packet[:content] = doc.to_s
        end
      end
    end
  end
end