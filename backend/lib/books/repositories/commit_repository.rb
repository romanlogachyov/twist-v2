class CommitRepository < Hanami::Repository
  associations do
    belongs_to :branch
  end

  def latest_for_branch(branch_id)
    by_branch(branch_id)
      .order { created_at.desc }
      .limit(1)
      .one!
  end

  def by_id(id)
    commits.by_pk(id).one
  end

  def by_ids(ids)
    commits.where(id: ids).to_a
  end

  def find_and_clean_or_create(branch_id, sha, chapter_repo)
    fields = { branch_id: branch_id, sha: sha }

    commit = commits.where(fields).limit(1).one
    if commit
      chapter_repo.wipe(commit.id)
      commit
    else
      create(fields)
    end
  end

  private

  def by_branch(branch_id)
    commits.where(branch_id: branch_id)
  end
end
