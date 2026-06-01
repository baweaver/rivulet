# frozen_string_literal: true

require_relative "lib/rivulet/version"

Gem::Specification.new do |spec|
  spec.name = "rivulet"
  spec.version = Rivulet::VERSION
  spec.authors = ["Brandon Weaver"]
  spec.email = ["keystonelemur@gmail.com"]

  spec.summary = "Sliding window operations for Ruby collections"
  spec.description = "A small stream with a bit of state flowing through it. Rivulet gives Ruby a vocabulary for sliding window operations — the grow-shrink-emit pattern that Enumerable never named."
  spec.homepage = "https://github.com/baweaver/rivulet"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/baweaver/rivulet"
  spec.metadata["changelog_uri"] = "https://github.com/baweaver/rivulet/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ benchmarks/ examples/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
