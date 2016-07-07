# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress", sticky: true) if pr_title.include? "[WIP]"

# Prevent PRs from deleting the travis config file
deleted = git.deleted_files.include? ".travis.yml"
fail("Don't delete the CI configuration file", sticky: true) if deleted

# FAIL REALLY BIG DIFFS
fail "We cannot handle the scale of this PR" if git.lines_of_code > 50_000

# WARN WHEN THERE ARE MERGE COMMITS IN THE DIFF
if commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
   warn('Please rebase to get rid of the merge commits in this PR', sticky: true)
end

# ENSURE THERE IS A SUMMARY FOR A PR
fail("Please provide a summary in the Pull Request description", sticky: true) if github.pr_body.length < 5

# Warn when there is a big PR
warn("Big PR") if lines_of_code > 500

# Run SwiftLint
swiftlint.lint_files
