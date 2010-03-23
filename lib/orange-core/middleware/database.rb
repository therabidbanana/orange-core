require 'orange-core/middleware/base'
module Orange::Middleware
  
  class Database < Base
    def init(opts = {})
      opts = opts.with_defaults(:migration_url => (orange.options[:development_mode] ? '/__ORANGE_DB__/migrate' : false), :no_auto_upgrade => false)
      orange.mixin Orange::Mixins::DBLoader
      orange.register(:stack_loaded) do |stack|
        db = orange.options['database'] || 'sqlite3::memory:'
        orange.load_db!(db)
        orange.upgrade_db! unless opts[:no_auto_upgrade] || orange.options['no_auto_upgrade']
      end
      @options = opts
    end
    def packet_call(packet)
      path = packet['route.path'] || packet.request.path_info
      if @options[:migration_url] && @options[:migration_url] == path
        orange.migrate_db!
        after = packet.session['flash.redirect_to'] ? packet.session['flash.redirect_to'] : '/'
        packet.reroute(after)
      end
      pass packet
    end
  end
  
end

module Orange::Mixins::DBLoader
  def load_db!(url)
    DataMapper.setup(:default, url)
  end
  
  def migrate_db!
    DataMapper.auto_migrate!
  end
  
  def upgrade_db!
    DataMapper.auto_upgrade!
  end
  
end