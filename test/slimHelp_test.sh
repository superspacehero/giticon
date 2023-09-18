#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)

"$PROJECT_ROOT"/commit.sh --version

show_slim_help

# Load and run shUnit2.
. shunit2