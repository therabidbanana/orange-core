require 'orange/router'

module Orange
  class ModelResource < RoutableResource
    
    def self.use(model_class)
      @@model_class = model_class
    end
    
    def view(packet, *args)
      opts = args.extract_options!.with_defaults({:mode => :show, :path => ''})
      props = @@model_class.form_props(packet[:context])
      
      resource_id = opts[:id] || packet[:resource_id] || false      
      
      haml_opts = {:props => props, :resource => self.class.to_s, :model_name => @my_orange_name}.merge!(opts)
      
      case opts[:mode]
      when :show
        haml_opts.with_defaults! :model => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('show.haml', packet, haml_opts)
      when :edit
        haml_opts.with_defaults! :model => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('edit.haml', packet, haml_opts)
      when :create
        haml_opts.with_defaults! :model => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('create.haml', packet, haml_opts)
      when :table_row
        haml_opts.with_defaults! :model => findOne(packet, opts[:mode], resource_id)
        orange[:parser].haml('table_row.haml', packet, haml_opts)
      when :list
        haml_opts.with_defaults! :list => findList(packet, opts[:mode])
        orange[:parser].haml('list.haml', packet, haml_opts)
      else
        'other'
      end
    end
    
    def findOne(packet, mode, id = false)
      return false unless id
      @@model_class.get(id) 
    end
    
    def findList(packet, mode)
      @@model_class.all || []
    end
    
    def viewExtras(packet, mode)
      {}
    end
    
    def route(path, packet)
      parts = path.split('/')
      if parts[0] =~ /^[0-9]+$/
        route_id = parts.shift 
      else 
        route_id = false
      end
      parts.unshift('show') if parts.empty? && route_id
      new_path = parts.join('/')
      packet[:resource_id] = route_id if route_id
      super(new_path, packet)
    end
    
    def new(path, packet)
      if packet.request.post?
        @@model_class.new(packet.request.params[@my_orange_name.to_s]).save
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def delete(path, packet)
      if packet.request.post?
        m = @@model_class.get(packet[:resource_id])
        m.destroy! if m
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    def save(path, packet)
      if packet.request.post?
        m = @@model_class.get(packet[:resource_id])
        if m
          m.update(packet.request.params[@my_orange_name.to_s])
        end
      end
      packet.reroute(@my_orange_name, :orange)
    end
    
    
    def show(path, packet)
      view(packet, :path => path, :mode => :show)
    end
    
    def edit(path, packet)
      view(packet, :path => path, :mode => :edit)
    end
    
    def create(path, packet)
      view(packet, :path => path, :mode => :create)
    end
    
    def table_row(path, packet)
      view(packet, :path => path, :mode => :table_row)
    end
    
    def list(path, packet)
      view(packet, :path => path, :mode => :list)
    end
    
    def index(path, packet)
      view(packet, :path => path, :mode => :list)
    end
  
  end
  
  class Packet
    def form_link(text, link, confirm = false)
      if confirm
        "<form action='#{link}' method='post' class='mini' onsubmit='return confirm(\"#{confirm}\")'><button class='link_button'><a href='#'>#{text}</a></button></form>"
      else
        "<form action='#{link}' method='post' class='mini'><button class='link_button'><a href='#'>#{text}</a></button></form>"
      end
    end
    
    def view(model_name, *args)
      orange[model_name].view(self, *args)
    end
    
    def view_attribute(prop, model_name, *args)
      args = args.extract_options!
      val = args[:value] || ''
      label = args[:label] || false
      show = args[:show] || false
      name = prop[:name]
      if !show
        case prop[:type]
        when :title
          ret = "<input class='title' type='text' value='#{val}' name='#{model_name}[#{name}]' />"
        when :text
          ret = "<input type='text' value='#{val}' name='#{model_name}[#{name}]' />"
        when :fulltext
          ret = "<textarea name='#{model_name}[#{name}]'>#{val}</textarea>"
        end
        ret = "<label for=''>#{name}</label><br />" + ret if label
      else
        case prop[:type]
        when :title
          ret = "<h3 class='#{model_name}-#{name}'>#{val}</h3>"
        when :text
          ret = "<p class='#{model_name}-#{name}'>#{val}</p>"
        when :fulltext
          ret = "<div class='#{model_name}-#{name}'>#{val}</div>"
        end
      end
      ret
    end
  end
end