describe Orange do
  it "should allow core mixin via mixin method" do
    c= Orange::Core.new
    c.should_not respond_to(:mixin_orange_one)
    Orange.mixin MockMixinOrange1
    c2= Orange::Core.new
    c.should respond_to(:mixin_orange_one)
    c2.should respond_to(:mixin_orange_one)
  end
  it "should allow pulp mixin via pulp method" do
    c= Orange::Core.new
    p= Orange::Packet.new(c, {})
    p.should_not respond_to(:pulp_orange_one)
    Orange.add_pulp MockPulpOrange1
    p2= Orange::Packet.new(c, {})
    p.should respond_to(:pulp_orange_one)
    p2.should respond_to(:pulp_orange_one)
  end
  it "should allow plugins" do
    Orange.plugins.should have(0).items
    Orange.plugin(MockPlugin.new)
    Orange.plugins.should have(1).items
    Orange.plugins([:foo, :bar]).should have(0).items
    Orange.plugins([:mock_plugin]).should have(1).items
    c= Orange::Core.new(:plugins => [:foo, :bar])
    c.plugins.should have(0).items
    c2= Orange::Core.new(:plugins => [:mock_plugin])
    c2.plugins.should have(1).items
  end
end