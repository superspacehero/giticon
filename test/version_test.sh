#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

"$PROJECT_ROOT"/commit.sh --version

testVersionParam() {
  actual="$("$commit_sh" --version)"

  echo "----"
  echo "actual = $actual"
  echo "----"

  assertContains 1002 "USAGE" "$actual"
}

# Load and run shUnit2.
. shunit2