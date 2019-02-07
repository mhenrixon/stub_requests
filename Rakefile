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
    --markup=markdown
    --markup-provider=redcarpet
    --readme README.md
  ]
end

task default: :spec

namespace :stub_requests do
  task :release do
    sh("./update_docs.sh")
    Rake::Task["changelog"].invoke
    sh("gem release --tag --push")
    sh("gem bump")
  end
end
