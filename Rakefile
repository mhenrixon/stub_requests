# frozen_string_literal: true

require "bundler/gem_tasks"

Dir.glob("#{File.expand_path(__dir__)}/lib/tasks/**/*.rake").each { |f| import f }

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "yard"
YARD::Rake::YardocTask.new do |t|
  t.files   = %w[lib/stub_requests/**/*.rb"]
  t.options = %w[
    --no-private
    --output-dir docs
    --readme README.md
    --output-dir docs
    --markup=markdown
    --markup-provider=redcarpet
  ]
end

task default: :spec
