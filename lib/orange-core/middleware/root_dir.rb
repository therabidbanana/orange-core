require 'orange-core/middleware/base'

module Orange::Middleware
  # This middleware handles sites in subdirs
  class RootDir < Base
    def packet_call(packet)
      request = packet.request
      path_info = packet['route.path'] || packet.env['PATH_INFO']
      unless(orange.options['root_dir'].blank?)
        packet['route.root_dir'] = orange.options['root_dir']
        path_info = path_info.sub(orange.options['root_dir'], "/")
        packet['route.path'] = path_info.blank? ? "/" : path_info
      end
      pass packet
    end
  end
end