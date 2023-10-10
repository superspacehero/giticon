#!/bin/sh
# shellcheck disable=SC2154

PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testGitAndOurFlags_C002() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  # Test our flag and git flags
  unset flag_type git_commit_params
  run_init
  run_stage_A_1 "--type" "feat" "--dry-run" "--amend"

  assertContains "flag_type contains \"feat\"" "$flag_type" "feat"
  assertContains "git params contain \"amend\"" "$git_commit_params" "amend"

  # Test git flags and our flag
  unset flag_type git_commit_params
  run_init
  run_stage_A_1  "--dry-run" "--type" "feat" "--amend"

  assertContains "git params contains \"dry-run\"" "$git_commit_params" "dry-run"
  assertContains "flag_type contains \"feat\"" "$flag_type" "feat"
  assertContains "git params contain \"amend\"" "$git_commit_params" "amend"
}

# Load and run shUnit2.
. shunit2
