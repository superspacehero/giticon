#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

TESTING_MODE=49474

testReadyForTest() {

  ready_test=true

  . $commit_sh

  set_test_id

  assertEquals "$test_id" "49474"
}

# Load and run shUnit2.
. shunit2
