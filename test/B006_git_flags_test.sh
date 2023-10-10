#!/bin/sh
# shellcheck disable=SC2154

PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testGitFlagsB006() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  # Test one arg
  unset git_commit_params
  run_init
  run_stage_A_1 "--amend"
  assertContains "git params contain \"amend\"" "$git_commit_params" "amend"

  # Test two args
  unset git_commit_params
  run_init
  run_stage_A_1 "--amend" "--dry-run"
  assertContains "git params contain \"amend\"" "$git_commit_params" "amend"
  assertContains "git params contain \"dry-run\"" "$git_commit_params" "dry-run"

  # Testing every git commit parameter here, in this manner, will not confirm
  # that our list is correct.
}

# Load and run shUnit2.
. shunit2
