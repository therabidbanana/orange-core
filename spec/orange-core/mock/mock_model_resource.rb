class MockModelResource < Orange::ModelResource
  use MockCarton
end

class MockNestedResource < Orange::ModelResource
  nests_in :products
end

class MockNestingResource < Orange::ModelResource
  nests_many :photo
  nests_in :category
end

class MockCategoryResource < Orange::ModelResource
  nests_many :products
end

class MockModelResourceOne < Orange::ModelResource
  use MockCarton
  def index(packet, *args)
    raise 'I see you\'re using index'
  end
  def show(packet, *args)
    raise 'I see you\'re using show'
  end
  def other(packet, *args)
    raise 'I see you\'re using other'
  end
  def find_one(packet, mode, resource_id =false)
    raise 'calling find_one'
  end
  def find_list(packet, mode)
    raise 'calling find_list'
  end
end

class MockModelResourceTwo < Orange::ModelResource
  use MockCartonTwo
end

class MockModelResourceThree < Orange::ModelResource
  use MockCarton
  def find_extras(packet, mode)
    raise 'calling find_extras'
  end
end

class MockModelResourceFour < Orange::ModelResource
  use MockCarton
  def find_one(packet, mode, resource_id =false)
    'mock_one'
  end
  def find_list(packet, mode)
    'mock_list'
  end
end

class MockModelResourceExtreme < Orange::ModelResource
  
end