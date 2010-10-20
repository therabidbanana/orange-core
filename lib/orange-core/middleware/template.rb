require 'orange-core/core'
require 'orange-core/middleware/base'

module Orange::Middleware
  
  class Template < Base
    def init(*args)
      @core.add_pulp(Orange::Pulp::Template)
      @core.mixin(Orange::Mixins::Template)
      
    end
    
    def packet_call(packet)
      packet['template.file'] = orange.template_for packet
      status, headers, content = pass packet
      if needs_wrapped?(packet)
        content = wrap(packet, content)
        packet[:content] = content.first
        orange.fire(:wrapped, packet)
      end  
      orange.fire(:after_wrap, packet)
      packet.finish
    end
    
    def needs_wrapped?(packet)
      return false if packet.request.xhr? && !packet['template.enable'] # don't wrap xhr unless specifically asked to
      packet['template.file'] && !packet['template.disable'] 
    end
    
    def wrap(packet, content = false)
      content = packet.content unless content
      content = content.join
      content = orange[:parser].tilt(packet['template.file'], packet, :wrapped_content => content, :template => true) do 
        content
      end
      [content]
    end
  end
end

module Orange::Pulp::Template
  def wrap
    packet[:content] = orange[:parser].tilt(packet['template.file'], packet, :wrapped_content => packet[:content], :template => true) do
      content
    end
  end
  def template(name)
    name = orange[:parser].view_name(self, name)
    packet['template.file'] == name
  end
  
  def layout(name)
    template(name)
  end
end

module Orange::Mixins::Template
  def template_for(packet)
    template_chooser.call(packet) || 'layout'
  end
  def template_chooser(&block)
    if block_given?
      @template_chooser = Proc.new
    else
      @template_chooser ||= Proc.new {|packet| false}
    end
  end
end