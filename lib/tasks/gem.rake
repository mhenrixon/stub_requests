# frozen_string_literal: true

namespace :gem do
  task :bump do
    system("gem bump ")
  end

  task :release do
    system("gem release ")
  end

  task :tag do
    system("gem tag")
  end
end
