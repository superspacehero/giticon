#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"
giticon_rc="${PROJECT_ROOT}/.giticon.rc"
commit_types_csv="${PROJECT_ROOT}/commit_types.csv"

testExecuteCommitY_H001() {
  # Run in the project directory
  actual="$("$commit_sh" --type feat "Block git commit" --dry-run)"

  assertContains "Ran with --dry-run" "$actual" "Changes not staged for commit"
}

# Load and run shUnit2.
. shunit2
