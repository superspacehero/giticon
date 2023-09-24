#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testTitleArg_C006() {
  actual="$("$commit_sh" "do something")"

  expecting="git commit -m "do something

  assertContains "$actual" "!"
}

# Load and run shUnit2.
. shunit2
