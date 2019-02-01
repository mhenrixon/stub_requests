# frozen_string_literal: true

namespace :git do
  desc "Run ssh-add to enter password for your ssh key a single time"
  task :setup do
    sh "ssh-add"
  end

  desc "Stage any deleted files to prepare for commit"
  task :delete do
    sh "git ls-files --deleted -z | xargs -0 git rm"
  end

  desc "Add files, commit them, push them"
  task :checkin do
    do_checkin
  end

  desc "Tests showing argument"
  task :show_arg, [:param1] do |_t, args|
    puts "Param1 is: #{args.param1}"
  end

  desc "Git Status"
  task :status do
    sh "git status"
  end

  def do_checkin
    print "Enter commit message to add, commit and push files, or blank to quit:\n"
    commit_message = STDIN.gets.chomp
    if commit_message.nil?
      print "Commit aborted."
      return
    end
    sh "git add ."
    sh "git commit -m\"#{commit_message}\""
    sh "git push"
  end
end
