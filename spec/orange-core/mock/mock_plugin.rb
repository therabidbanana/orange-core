
class MockPlugin < Orange::Plugins::Base
  assets_dir      File.join('assets')
  views_dir       File.join('views')
  templates_dir   File.join('templates')
  resource MockResource.new
end