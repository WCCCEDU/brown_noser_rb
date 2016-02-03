class ProjectRepoSearcher
  def search(query)
    finds = `git grep "#{query}" $(git rev-list --all)`
    puts finds
    finds
  end
end
