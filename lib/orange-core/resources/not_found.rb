require 'orange-core/resource'
module Orange
  class NotFound < Orange::Resource
    call_me :not_found
    def route(packet)
      packet[:content] = orange[:parser].tilt("404", packet, :resource => self)
      packet[:status] = 404
    end
  end
end