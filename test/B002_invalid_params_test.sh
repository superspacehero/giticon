#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)

testInvalidParams_B002() {

  error_num=104

  # Capture the exit code
  "${PROJECT_ROOT}"/commit.sh --verj >/dev/null
  exit_code=$?

  assertSame "Expected exit code, $error_num" "$error_num" "$exit_code"
}

# Load and run shUnit2.
. shunit2
