#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testExecuteCommitY_H001() {
  temp=$EXECUTE_COMMIT
  EXECUTE_COMMIT="y"
  actual="$("$commit_sh" --dry-run --type feat "Block git commit")"
  EXECUTE_COMMIT=$temp
  unset temp

  echo "$actual"
#  assertContains "$actual" "USAGE:"
}

testExecuteCommitN_H001() {
  temp=$EXECUTE_COMMIT
  EXECUTE_COMMIT="y"
  actual="$("$commit_sh" --dry-run --type feat "Block git commit")"
  EXECUTE_COMMIT=$temp
  unset temp

  echo "$actual"
#  assertContains "$actual" "USAGE:"
}

# Load and run shUnit2.
. shunit2
