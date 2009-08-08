# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{iseq_parser}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Macario Ortega"]
  s.date = %q{2009-08-08}
  s.description = %q{FIX (describe your package)}
  s.email = ["macarui@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/iseq_parser.rb", "lib/test.rb", "spec/basic_spec.rb", "spec/hello_yarv.rb", "spec/klass.rb", "spec/method_arguments_extraction_spec.rb", "spec/spec_helper.rb", "spec/structures_spec.rb", "spec/test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/#{github_username}/#{project_name}}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{iseq_parser}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{FIX (describe your package)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sexp_processor>, [">= 3.0.1"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<sexp_processor>, [">= 3.0.1"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<sexp_processor>, [">= 3.0.1"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
