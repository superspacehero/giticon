#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testHelpParams() {
  actual="$("$commit_sh" --help >/dev/null)"

  assertContains "$actual" "USAGE:"
}

# Load and run shUnit2.
. shunit2