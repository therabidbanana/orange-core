class MockResource < Orange::Resource
  def mock_method
    'MockResource#mock_method'
  end
  def afterLoad
    @options[:mocked] = true
  end
end

class MockResourceTwo < Orange::Resource
  def mock_method
    'MockResource#mock_method'
  end
  def afterLoad
    @options[:mocked] = true
  end
  def stack_init
    true
  end
end

class MockParser < Orange::Resource
  def tilt(template, packet, opts)
    [template, packet, opts]
  end
  def haml(template, packet, opts)
    [template, packet, opts]
  end
end