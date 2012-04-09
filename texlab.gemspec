# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "texlab"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bern\u{e1}t Kall\u{f3}"]
  s.date = "2012-04-09"
  s.description = "texlab a toolkit based on erb that for creating documents and doing calculations at the same time. It is capable to output the proper number of significant digits, generate tables and plots using gnuplot. It has a simple DSL."
  s.email = "kallo.bernat@gmail.com"
  s.executables = ["texlab-compile"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc",
    "README.txt"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "README.txt",
    "Rakefile",
    "VERSION",
    "bin/texlab-compile",
    "bin/texlab-compile.tex",
    "bin/texlab-console",
    "doc/readme.texlab",
    "lib/texlab.rb",
    "lib/texlab/boot.rb",
    "lib/texlab/texlabfile.rb",
    "spec/spec_helper.rb",
    "spec/texlab_spec.rb",
    "texlab",
    "texlab.gemspec",
    "vim/texlab.vim"
  ]
  s.homepage = "http://github.com/cie/texlab"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "a tool to create documents with latex and ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake4latex>, [">= 0"])
      s.add_runtime_dependency(%q<plusminus>, [">= 0"])
      s.add_runtime_dependency(%q<easystats>, [">= 0"])
      s.add_runtime_dependency(%q<to_latex>, [">= 0"])
      s.add_runtime_dependency(%q<gnuplot>, [">= 0"])
      s.add_runtime_dependency(%q<latex>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rake4latex>, [">= 0"])
      s.add_dependency(%q<plusminus>, [">= 0"])
      s.add_dependency(%q<easystats>, [">= 0"])
      s.add_dependency(%q<to_latex>, [">= 0"])
      s.add_dependency(%q<gnuplot>, [">= 0"])
      s.add_dependency(%q<latex>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake4latex>, [">= 0"])
    s.add_dependency(%q<plusminus>, [">= 0"])
    s.add_dependency(%q<easystats>, [">= 0"])
    s.add_dependency(%q<to_latex>, [">= 0"])
    s.add_dependency(%q<gnuplot>, [">= 0"])
    s.add_dependency(%q<latex>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end
