require 'orange-core/core'
require 'haml'
require 'tilt'
require 'yaml'
require 'crack'

module Orange
  class Parser < Resource
    def afterLoad
      orange.add_pulp Orange::Pulp::ParserPulp
      @template_dirs = [[File.join(orange.core_dir, 'templates'), "haml"]]
      @view_dirs = [[File.join(orange.core_dir, 'views'), "haml"]]
      orange.plugins.each{|p| @template_dirs << [p.templates, p.template_type] if p.has_templates? }
      orange.plugins.each{|p| @view_dirs << [p.views, p.template_type] if p.has_views? }
    end
    
    def view_name(packet, name, preferred_ext = "haml")
      name = name.to_s if name.kind_of?(Symbol)
      name = "#{name}.#{preferred_ext}" if File.extname(name).blank?
      name
    end

    def yaml(file)
      return nil unless File.exists?(file)
      string = File.read(file) 
      string.gsub!('__ORANGE__', orange.app_dir)
      out = YAML::load(string)
    end
    
    def tilt(file, binding_obj, *vars, &block)
      opts = vars.extract_options!
      # Initial info
      file_with_ext = view_name(binding_obj, file)
      
      temp = opts.delete(:template)
      opts[:resource_name] = opts[:resource].orange_name.to_s if 
          opts[:resource] && opts[:resource].respond_to?(:orange_name)
      resource = (opts[:resource_name] || '').downcase
      
      opts.merge :orange => orange
      if binding_obj.is_a? Orange::Packet
        context = binding_obj['route.context'].to_s
      end      
      tilt = tilt_if_exists(file_with_ext) 
      if temp
        tilt ||= tilt_if_exists('templates', file_with_ext) 
        @template_dirs.reverse_each do |templates_dir|
          templates_dir, extname = templates_dir
          tilt ||= tilt_if_exists(templates_dir, view_name(binding_obj, file, extname))
        end unless tilt
      end
    
      if context
        #Check for context specific overrides
        tilt ||= tilt_if_exists('views', resource, context+"."+file_with_ext) if resource
        tilt ||= tilt_if_exists('views', context+"."+file_with_ext) unless resource
        @view_dirs.reverse_each do |views_dir|
          views_dir, extname = views_dir
          tilt ||= tilt_if_exists(views_dir, resource, context+"."+view_name(binding_obj, file, extname)) if resource
          tilt ||= tilt_if_exists(views_dir, context+"."+view_name(binding_obj, file, extname)) unless resource
        end unless tilt
      end
    
      # Check for standard views
      tilt ||= tilt_if_exists('views', resource, file_with_ext) if resource
      tilt ||= tilt_if_exists('views', file_with_ext) unless resource
      @view_dirs.reverse_each do |views_dir|
        views_dir, extname = views_dir
        tilt ||= tilt_if_exists(views_dir, resource, view_name(binding_obj, file, extname)) if resource
        tilt ||= tilt_if_exists(views_dir, view_name(binding_obj, file, extname)) unless resource
      end unless tilt
    
      # Check for default resource views
      tilt ||= tilt_if_exists('views', 'default_resource', file)
      @view_dirs.reverse_each do |views_dir|
        views_dir, extname = views_dir
        tilt ||= tilt_if_exists(views_dir, 'default_resource', view_name(binding_obj, file, extname)) if resource
      end unless tilt
      raise LoadError, "Couldn't find view file '#{file}'" unless tilt
      
      opts[:opts] = opts.dup
      out = tilt.render(binding_obj, opts, &block)
    end
    
    def haml(file, packet_binding, *vars, &block)
      
      opts = vars.extract_options!
      # Initial info
      temp = opts.delete(:template)
      opts[:resource_name] = opts[:resource].orange_name.to_s if 
          opts[:resource] && opts[:resource].respond_to?(:orange_name)
      resource = (opts[:resource_name] || '').downcase
      
      file_with_ext = view_name(packet_binding, file, "haml")
      opts.merge :orange => orange
      if packet_binding.is_a? Orange::Packet
        context = packet_binding['route.context'].to_s
        unless temp
          packet_binding['parser.haml-templates'] ||= {}
          haml_engine = packet_binding['parser.haml-templates']["#{context}-#{resource}-#{file}"] || false
        end
      end
      unless haml_engine
      
        string = false
        if temp
          string ||= read_if_exists('templates', file_with_ext) 
          @template_dirs.reverse_each do |templates_dir|
            templates_dir, extname = templates_dir
            string ||= read_if_exists(templates_dir, file_with_ext)
          end unless string
        end
      
        if context
          #Check for context specific overrides
          string ||= read_if_exists('views', resource, context+"."+file_with_ext) if resource
          string ||= read_if_exists('views', context+"."+file_with_ext) unless resource
          @view_dirs.reverse_each do |views_dir|
            views_dir, extname = views_dir
            string ||= read_if_exists(views_dir, resource, context+"."+file_with_ext) if resource
            string ||= read_if_exists(views_dir, context+"."+file_with_ext) unless resource
          end unless string
        end
      
        # Check for standard views
        string ||= read_if_exists('views', resource, file_with_ext) if resource
        string ||= read_if_exists('views', file_with_ext) unless resource
        @view_dirs.reverse_each do |views_dir|
          views_dir, extname = views_dir
          string ||= read_if_exists(views_dir, resource, file_with_ext) if resource
          string ||= read_if_exists(views_dir, file_with_ext) unless resource
        end unless string
      
        # Check for default resource views
        string ||= read_if_exists('views', 'default_resource', file_with_ext)
        @view_dirs.reverse_each do |views_dir|
          views_dir, extname = views_dir
          string ||= read_if_exists(views_dir, 'default_resource', file_with_ext) if resource
        end unless string
        raise LoadError, "Couldn't find haml file '#{file_with_ext}'" unless string
        
        haml_engine = Haml::Engine.new(string)
        if packet_binding.is_a? Orange::Packet
          packet_binding['parser.haml-templates', {}]["#{context}-#{resource}-#{file}"] = haml_engine
        end
      end
      opts[:opts] = opts.dup
      out = haml_engine.render(packet_binding, opts, &block)
    end
    
    def read_if_exists(*args)
      return File.read(File.join(*args)) if File.exists?(File.join(*args))
      false
    end
    
    def tilt_if_exists(*args)
      return Tilt.new(File.join(*args)) if File.exists?(File.join(*args))
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