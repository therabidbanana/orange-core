class Main < Orange::Application
  stack do
    orange.options[:development_mode] = true
    orange.options[:main_user] = "therabidbanana@gmail.com"
    
    use Rack::Session::Cookie, :secret => 'osb_secret'
    auto_reload!
    use_exceptions
    
    # use Rack::OpenID, OpenIDDataMapper::DataMapperStore.new
    prerouting 

    routing :exposed_actions => {:live => :all, :admin => :all, :orange => :all}
    
    postrouting
    # orange.add_pulp(SparkleHelpers)
    run Main.new(orange)
  end
end