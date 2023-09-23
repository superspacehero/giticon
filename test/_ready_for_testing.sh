#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

TESTING_ID=49474

testReadyForTest() {

  ready_test=true
  test_only=true

  . $commit_sh

  set_test_id

  assertEquals "$test_id" "$TESTING_ID"
}

# Load and run shUnit2.
. shunit2
