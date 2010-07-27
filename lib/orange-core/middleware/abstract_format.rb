require 'orange-core/middleware/base'
require 'pathname'

module Orange::Middleware
  # This is an adapted Orange version of mynyml's rack-abstract-format
  # available at http://github.com/mynyml/rack-abstract-format 
  class AbstractFormat < Base
    def init(opts = {})
    end
    
    def packet_call(packet)
      path_info = packet['route.path'] || packet.env['PATH_INFO']
      path = Pathname(path_info)
      packet['route.path'] = path.to_s.sub(/#{path.extname}$/,'') if Rack::Mime::MIME_TYPES.include?(path.extname)
      packet.env['HTTP_ACCEPT'] = concat(packet.env['HTTP_ACCEPT'], Rack::Mime.mime_type(path.extname))
      
      pass packet
    end
    
    private
      def concat(accept, type)
        (accept || '').split(',').unshift(type).compact.join(',')
      end
  end
end

# 
# Copyright © 2009 Martin Aumont (mynyml)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.