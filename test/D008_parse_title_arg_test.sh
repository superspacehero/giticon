#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testParseLoneTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

testParseTypeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

testParseScopeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

testParseScopeNoDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

testParseIconTypeTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

testParseIconTypeScopeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "why we did it" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" false
}

# Load and run shUnit2.
. shunit2
