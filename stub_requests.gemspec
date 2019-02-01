
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stub_requests/version"

Gem::Specification.new do |spec|
  spec.name          = "stub_requests"
  spec.version       = StubRequests::VERSION
  spec.authors       = ["Mikael Henriksson"]
  spec.email         = ["mikael@zoolutions.se"]

  spec.summary       = %q{Abstraction over WebMock}
  spec.description   = %q{An abstraction on top of WebMock to build stubbed HTTP requests}
  spec.homepage      = "https://mhenrixon.github.io/stub_requests/"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mhenrixon/stub_requests"
    spec.metadata["changelog_uri"] = "https://github.com/mhenrixon/stub_requests/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "docile",          "~> 1.0", "< 2"
  spec.add_dependency "webmock",         "~> 3.0", "< 4.0"
  spec.add_dependency "concurrent-ruby", "~> 1.0", "< 2"
  spec.add_dependency "public_suffix",   "~> 3.0", "< 4"

  # ===== Basics =====
  spec.add_development_dependency "bundler",        ">= 2.0"
  spec.add_development_dependency "rake",           ">= 10.0"

  # ===== Testing =====
  spec.add_development_dependency "json_spec",      ">= 1.1.5"
  spec.add_development_dependency "rspec",          ">= 3.8"
  spec.add_development_dependency "rspec-its",      ">= 1.2"
  spec.add_development_dependency "rubocop",        "~> 0.63.1"
  spec.add_development_dependency "rubocop-rspec",  "~> 1.32"
  spec.add_development_dependency "simplecov",      ">= 0.16.1"
  spec.add_development_dependency "simplecov-json", ">= 0.2"
  spec.add_development_dependency "reek",           ">= 5.0"

  # ===== Debugging  =====
  spec.add_development_dependency "pry",            ">= 0.12"

  # ===== Utilities =====
  spec.add_development_dependency "travis",         ">= 1.8.9"

  # ===== Documentation =====
  spec.add_development_dependency "yard",           "~> 0.9.18"

  # ===== Release Management =====
  spec.add_development_dependency "gem-release", ">= 2.0"
  spec.add_development_dependency "github_changelog_generator", "~> 1.14"
end
