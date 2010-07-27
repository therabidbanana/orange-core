# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{orange-core}
  s.version = "0.5.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Haslem"]
  s.date = %q{2010-07-10}
  s.description = %q{Orange is a Ruby framework for building managed websites with code as simple as Sinatra}
  s.email = %q{therabidbanana@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "lib/orange-core.rb",
     "lib/orange-core/application.rb",
     "lib/orange-core/assets/css/exceptions.css",
     "lib/orange-core/assets/js/exceptions.js",
     "lib/orange-core/carton.rb",
     "lib/orange-core/core.rb",
     "lib/orange-core/magick.rb",
     "lib/orange-core/middleware/base.rb",
     "lib/orange-core/middleware/database.rb",
     "lib/orange-core/middleware/four_oh_four.rb",
     "lib/orange-core/middleware/globals.rb",
     "lib/orange-core/middleware/loader.rb",
     "lib/orange-core/middleware/rerouter.rb",
     "lib/orange-core/middleware/restful_router.rb",
     "lib/orange-core/middleware/route_context.rb",
     "lib/orange-core/middleware/route_site.rb",
     "lib/orange-core/middleware/show_exceptions.rb",
     "lib/orange-core/middleware/static.rb",
     "lib/orange-core/middleware/static_file.rb",
     "lib/orange-core/middleware/template.rb",
     "lib/orange-core/packet.rb",
     "lib/orange-core/plugin.rb",
     "lib/orange-core/resource.rb",
     "lib/orange-core/resources/mapper.rb",
     "lib/orange-core/resources/model_resource.rb",
     "lib/orange-core/resources/not_found.rb",
     "lib/orange-core/resources/page_parts.rb",
     "lib/orange-core/resources/parser.rb",
     "lib/orange-core/resources/routable_resource.rb",
     "lib/orange-core/resources/scaffold.rb",
     "lib/orange-core/stack.rb",
     "lib/orange-core/templates/exceptions.haml",
     "lib/orange-core/views/default_resource/create.haml",
     "lib/orange-core/views/default_resource/edit.haml",
     "lib/orange-core/views/default_resource/list.haml",
     "lib/orange-core/views/default_resource/show.haml",
     "lib/orange-core/views/default_resource/table_row.haml",
     "lib/orange-core/views/not_found/404.haml"
  ]
  s.homepage = %q{http://github.com/therabidbanana/orange-core}
  s.post_install_message = %q{===========================================
Note: 
orange-core requires DataMapper to function. dm-core has been installed,
but please make sure you also have installed the 
the appropriate DataMapper adapter for your system:

$ gem install [dm-adapter]

Mysql:    dm-mysql-adapter
Sqlite:   dm-sqlite-adapter
Postgres: dm-postgres-adapter

orange-core install complete.
===========================================
}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Middle ground between Sinatra and Rails}
  s.test_files = [
    "spec/orange-core/application_spec.rb",
     "spec/orange-core/carton_spec.rb",
     "spec/orange-core/core_spec.rb",
     "spec/orange-core/magick_spec.rb",
     "spec/orange-core/middleware/base_spec.rb",
     "spec/orange-core/middleware/globals_spec.rb",
     "spec/orange-core/middleware/rerouter_spec.rb",
     "spec/orange-core/middleware/restful_router_spec.rb",
     "spec/orange-core/middleware/route_context_spec.rb",
     "spec/orange-core/middleware/route_site_spec.rb",
     "spec/orange-core/middleware/show_exceptions_spec.rb",
     "spec/orange-core/middleware/static_file_spec.rb",
     "spec/orange-core/middleware/static_spec.rb",
     "spec/orange-core/mock/mock_app.rb",
     "spec/orange-core/mock/mock_carton.rb",
     "spec/orange-core/mock/mock_core.rb",
     "spec/orange-core/mock/mock_middleware.rb",
     "spec/orange-core/mock/mock_mixins.rb",
     "spec/orange-core/mock/mock_model_resource.rb",
     "spec/orange-core/mock/mock_pulp.rb",
     "spec/orange-core/mock/mock_resource.rb",
     "spec/orange-core/mock/mock_router.rb",
     "spec/orange-core/orange_spec.rb",
     "spec/orange-core/packet_spec.rb",
     "spec/orange-core/resource_spec.rb",
     "spec/orange-core/resources/mapper_spec.rb",
     "spec/orange-core/resources/model_resource_spec.rb",
     "spec/orange-core/resources/parser_spec.rb",
     "spec/orange-core/resources/routable_resource_spec.rb",
     "spec/orange-core/spec_helper.rb",
     "spec/orange-core/stack_spec.rb",
     "spec/stats.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0.1"])
      s.add_runtime_dependency(%q<haml>, [">= 2.2.13"])
      s.add_runtime_dependency(%q<crack>, [">= 0"])
      s.add_runtime_dependency(%q<dm-core>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<dm-migrations>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rack-abstract-format>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0.1"])
      s.add_dependency(%q<haml>, [">= 2.2.13"])
      s.add_dependency(%q<crack>, [">= 0"])
      s.add_dependency(%q<dm-core>, [">= 1.0.0"])
      s.add_dependency(%q<dm-migrations>, [">= 1.0.0"])
      s.add_dependency(%q<rack-abstract-format>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0.1"])
    s.add_dependency(%q<haml>, [">= 2.2.13"])
    s.add_dependency(%q<crack>, [">= 0"])
    s.add_dependency(%q<dm-core>, [">= 1.0.0"])
    s.add_dependency(%q<dm-migrations>, [">= 1.0.0"])
    s.add_dependency(%q<rack-abstract-format>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end

