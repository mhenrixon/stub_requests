
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stub_requests/version"

Gem::Specification.new do |spec|
  spec.name          = "stub_requests"
  spec.version       = StubRequests::VERSION
  spec.authors       = ["Mikael Henriksson"]
  spec.email         = ["mikael@zoolutions.se"]

  spec.summary       = %q{Stubs HTTP requests using webmock}
  spec.description   = %q{}
  spec.homepage      = "https://mhenrixon.github.io/stub_requests/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/mhenrixon/stub_requests"
    spec.metadata["changelog_uri"] = "https://github.com/mhenrixon/stub_requests/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "webmock" # TODO: Add version constraint
  spec.add_dependency "concurrent-ruby" # TODO: Add version constraint
  spec.add_dependency "public_suffix" # TODO: Add version constraint
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake" # TODO: Add version constraint
  spec.add_development_dependency "rspec" # TODO: Add version constraint
  spec.add_development_dependency "rspec-its" # TODO: Add version constraint
  spec.add_development_dependency "rubocop" # TODO: Add version constraint
  spec.add_development_dependency "rubocop-rspec" # TODO: Add version constraint
  spec.add_development_dependency "simplecov" # TODO: Add version constraint
  spec.add_development_dependency "simplecov-json" # TODO: Add version constraint
  spec.add_development_dependency "pry" # TODO: Add version constraint
  spec.add_development_dependency "reek" # TODO: Add version constraint
  spec.add_development_dependency "travis" # TODO: Add version constraint
  spec.add_development_dependency "gem-release" # TODO: Add version constraint
  spec.add_development_dependency "yard" # TODO: Add version constraint
end
