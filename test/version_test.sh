#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

"$PROJECT_ROOT"/commit.sh --version

testVersionParam() {
  actual="$("$commit_sh" --version >/dev/null)"

  assertContains "$actual" ".sh v"
}

# Load and run shUnit2.
. shunit2