# frozen_string_literal: true

desc "Generate a Changelog"
task :changelog do
  # rubocop:disable Style/MutableConstant
  CHANGELOG_CMD ||= %w[
    github_changelog_generator
    -u
    mhenrixon
    -p
    stub_requests
    --no-verbose
    --token
  ]
  CHECKOUT_CHANGELOG_CMD ||= "git checkout -B update-changelog"
  ADD_CHANGELOG_CMD      ||= "git add --all"
  COMMIT_CHANGELOG_CMD   ||= "git commit -a -m 'Update changelog'"
  GIT_PUSH_CMD           ||= "git push -u origin update-changelog"
  OPEN_PR_CMD            ||= "hub pull-request -b master  -m 'Update Changelog' -a mhenrixon -l changelog"
  # rubocop:enable Style/MutableConstant

  sh(*CHANGELOG_CMD.push(ENV["CHANGELOG_GITHUB_TOKEN"]))
  sh(CHECKOUT_CHANGELOG_CMD)
  sh(ADD_CHANGELOG_CMD)
  sh(COMMIT_CHANGELOG_CMD)
  sh(GIT_PUSH_CMD)
  sh(OPEN_PR_CMD)
end
