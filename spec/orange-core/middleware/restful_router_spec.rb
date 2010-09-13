describe Orange::Middleware::RestfulRouter do
  before :all do
    @router = Orange::Middleware::RestfulRouter.new(nil, Orange::Core.new)
  end
  before :each do
    @index = empty_packet(@router.orange)
    @index.orange.load(MockNestingResource.new, :products)
    @index.orange.load(MockNestedResource.new, :photo)
    @index.orange.load(MockCategoryResource.new, :category)
    @index.orange.load(MockResource.new, :special)
    @show_product_list = empty_packet(@index.orange)
    @show_product_list['route.path'] = '/products'
    @show_product_one = empty_packet(@index.orange)
    @show_product_one['route.path'] = '/products/1'
    @edit_product_two = empty_packet(@index.orange)
    @edit_product_two['route.path'] = '/products/2/edit'
    @edit_product_three_special = empty_packet(@index.orange)
    @edit_product_three_special['route.path'] = '/products/3/edit/special'
    @edit_product_three_photo = empty_packet(@index.orange)
    @edit_product_three_photo['route.path'] = '/products/3/photo/edit'
    @edit_product_very_nested = empty_packet(@index.orange)
    @edit_product_very_nested['route.path'] = '/category/1/view/products/3/photo/edit'
    @edit_product_three_photo_thumbnail = empty_packet(@index.orange)
    @edit_product_three_photo_thumbnail['route.path'] = '/products/3/photo/1/edit/thumbnail'
    @show_banana_list = empty_packet(@index.orange)
    @show_banana_list['route.path'] = '/bananas'
  end
  it "should not route if other middleware has" do
    @index['route.router'] = true
    @show_product_list['route.router'].should == false
    @router.should_receive(:pass).twice
    @router.should_receive(:should_route?).once.and_return(true)
    @router.packet_call(@index)
    @router.packet_call(@show_product_list)
    
  end
  it "should set router" do
    @router.should_receive(:pass).once
    @router.should_receive(:should_route?).once.and_return(true)
    @show_product_list['route.router'].should == false
    @router.packet_call(@show_product_list)
    @show_product_list['route.router'].should == @router
  end
  it "should set routing vars if should_route true" do
    @router.should_receive(:pass).at_least(:once)
    @router.should_receive(:should_route?).at_least(:once).and_return(true)
    @router.packet_call(@show_product_list)
    @show_product_list['route.resource'].should == :products
    @show_product_list['route.resource_action'].should == :list
    @show_product_list['route.resource_id'].should == false
    @show_product_one['route.resource_path'].should == false
    @router.packet_call(@show_product_one)
    @show_product_one['route.resource'].should == :products
    @show_product_one['route.resource_action'].should == :show
    @show_product_one['route.resource_id'].should == "1"
    @show_product_one['route.resource_path'].should == ""
    @router.packet_call(@edit_product_two)
    @edit_product_two['route.resource'].should == :products
    @edit_product_two['route.resource_action'].should == :edit
    @edit_product_two['route.resource_id'].should == "2"
    @show_product_one['route.resource_path'].should == ""
    @router.packet_call(@edit_product_three_special)
    @edit_product_three_special['route.nesting'].should == []
    @edit_product_three_special['route.resource'].should == :products
    @edit_product_three_special['route.resource_action'].should == :edit
    @edit_product_three_special['route.resource_id'].should == "3"
    @edit_product_three_special['route.resource_path'].should == "/special"
  end
  it "should handle nesting correctly" do
    @router.should_receive(:pass).at_least(:once)
    @router.should_receive(:should_route?).at_least(:once).and_return(true)
    @router.packet_call(@edit_product_three_special)
    @edit_product_three_special['route.nesting'].should == []
    @edit_product_three_special['route.resource'].should == :products
    @edit_product_three_special['route.resource_action'].should == :edit
    @edit_product_three_special['route.resource_id'].should == "3"
    @edit_product_three_special['route.resource_path'].should == "/special"
    @router.packet_call(@edit_product_three_photo)
    @edit_product_three_photo['route.nesting'].should_not == []
    @edit_product_three_photo['route.resource'].should == :photo
    @edit_product_three_photo['route.resource_action'].should == :edit
    @edit_product_three_photo['route.resource_path'].should == ""
    @router.packet_call(@edit_product_very_nested)
    @edit_product_very_nested['route.nesting'].length.should == 2
    @edit_product_very_nested['route.resource'].should == :photo
    @edit_product_very_nested['route.resource_action'].should == :edit
    @edit_product_very_nested['route.resource_path'].should == ""
    @edit_product_very_nested['route.nesting'].first[:resource].should == :category
    @edit_product_very_nested['route.nesting'].first[:resource_action].should == :view
    @edit_product_very_nested['route.nesting'].first[:resource_id].should == "1"
    @router.packet_call(@edit_product_three_photo_thumbnail)
    @edit_product_three_photo_thumbnail['route.nesting'].should_not == []
    @edit_product_three_photo_thumbnail['route.resource'].should == :photo
    @edit_product_three_photo_thumbnail['route.resource_action'].should == :edit
    @edit_product_three_photo_thumbnail['route.resource_id'].should == "1"
    @edit_product_three_photo_thumbnail['route.resource_path'].should == "/thumbnail"
  end
  
  
end