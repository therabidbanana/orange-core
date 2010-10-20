require 'ostruct'
require 'rack/request'
require 'rack/utils'
require 'orange-core/middleware/base'

module Orange::Middleware
  # Rack::ShowExceptions catches all exceptions raised from the app it
  # wraps.  It shows a useful backtrace with the sourcefile and
  # clickable context, the whole Rack environment and the request
  # data.
  #
  # Be careful when you use this on public-facing sites as it could
  # reveal information helpful to attackers.
  #
  # Orange::Middleware::ShowExceptions is a slightly modified
  # version of Rack::ShowExceptions
  class ShowExceptions < Base
    CONTEXT = 7

    def call(env)
      @app.call(env)
    rescue Exception => e
      if(orange.options[:development_mode])
        backtrace = pretty(env, e)
      
        return [500,
         {"Content-Type" => "text/html",
          "Content-Length" => backtrace.join.size.to_s},
         backtrace]
      else
        page = error_page(env)
        return [500, {"Content-Type" => "text/html",
          "Content-Length" => page.join.size.to_s},
         page]
      end
    end
    
    def packet_call(packet)
      backtrace = pretty()
    end
    
    def error_page(env)
      packet = Orange::Packet.new(@core, env)
      parse = orange[:parser].tilt("500", packet, :template => true)
      [parse]
    end

    def pretty(env, exception)
      req = Rack::Request.new(env)
      path = (req.script_name + req.path_info).squeeze("/")

      frames = exception.backtrace.map { |line|
        frame = OpenStruct.new
        if line =~ /(.*?):(\d+)(:in `(.*)')?/
          frame.filename = $1
          frame.lineno = $2.to_i
          frame.function = $4

          begin
            lineno = frame.lineno-1
            lines = ::File.readlines(frame.filename)
            frame.pre_context_lineno = [lineno-CONTEXT, 0].max
            frame.pre_context = lines[frame.pre_context_lineno...lineno]
            frame.context_line = lines[lineno].chomp
            frame.post_context_lineno = [lineno+CONTEXT, lines.size].min
            frame.post_context = lines[lineno+1..frame.post_context_lineno]
          rescue
          end

          frame
        else
          nil
        end
      }.compact

      env["rack.errors"].puts "#{exception.class}: #{exception.message}"
      env["rack.errors"].puts exception.backtrace.map { |l| "\t" + l }
      env["rack.errors"].flush
      orange_env = env["orange.env"]
      
      parse = orange[:parser].tilt("exceptions", self, :template => true, :exception => exception, :env => env, :orange_env => orange_env, :path => path, :frames => frames, :req => req)
      [parse]
    end

    def h(obj)                  # :nodoc:
      case obj
      when String
        Rack::Utils.escape_html(obj)
      else
        begin 
          Rack::Utils.escape_html(obj.inspect)
        rescue Exception => e
          "Object #{obj.class.to_s} could not be inspected"
        end
      end
    end
  end
end