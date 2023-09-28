#!/bin/sh
# shellcheck disable=SC2154

PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testParseLoneTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="do something"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="do something"
  actual=$arg_title

  assertEquals "> $test : title equals \"$expected\"" "$expected" "$actual"
}

testParseTypeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="fix: Correct conditional logic"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="fix"
  actual=$arg_type
  assertEquals "> $test : type equals \"$expected\"" "$expected" "$actual"
  expected=":"
  actual=$arg_delimiter
  assertEquals "> $test : delimiter equals \"$expected\"" "$expected" "$actual"
  expected="Correct conditional logic"
  actual=$arg_title
  assertEquals "> $test : title equals \"$expected\"" "$expected" "$actual"
}

testParseScopeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="(Android): Compensate for header"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="Android"
  actual=$arg_scope
  assertEquals "> $test : scope equals \"$expected" "$expected" "$actual"
  expected=":"
  actual=$arg_delimiter
  assertEquals "> $test : delimiter equals \"$expected" "$expected" "$actual"
  expected="Compensate for header"
  actual=$arg_title
  assertEquals "> $test : title equals \"$expected" "$expected" "$actual"
}

testParseScopeNoDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="(Android) Compensate for header"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="Android"
  actual=$arg_scope
  assertEquals "> $test : scope equals \"$expected" "$expected" "$actual"
  expected=""
  actual=$arg_delimiter
  assertEquals "> $test : delimiter equals \"$expected" "$expected" "$actual"
  expected="Compensate for header"
  actual=$arg_title
  assertEquals "> $test : title equals \"$expected" "$expected" "$actual"
}

testParseIconTypeTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="🎉 init: Add files to start search"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="🎉"
  actual=$arg_icon
  assertEquals "> $test : icon equals \"$expected" "$expected" "$actual"
  expected="init"
  actual=$arg_type
  assertEquals "> $test : type equals \"$expected" "$expected" "$actual"
  expected="Add files to start search"
  actual=$arg_title
  assertEquals "> $test : title equals \"$expected" "$expected" "$actual"
}

testParseIconTypeScopeDelimiterTitle_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test="⚗️ wip (sh)!Update cleanup script"

  run_init
  run_stage_A_1 "$test"
  run_stage_A_2

  expected="⚗️"
  actual=$arg_icon
  assertEquals "> $test : icon equals \"$expected" "$expected" "$actual"
  expected="wip"
  actual=$arg_type
  assertEquals "> $test : type equals \"$expected" "$expected" "$actual"
  expected="sh"
  actual=$arg_scope
  assertEquals "> $test : scope equals \"$expected" "$expected" "$actual"
  expected="!"
  actual=$arg_delimiter
  assertEquals "> $test : delimiter equals \"$expected" "$expected" "$actual"
  expected="Update cleanup script"
  actual=$arg_title
  assertEquals "> $test : title equals \"$expected" "$expected" "$actual"
}

reconstitute() {
  distill_arg_1 "$1"

  outstr=""

  if [ -n "$arg_delimiter" ]; then outstr="$arg_delimiter"; else outstr=""; fi
  if [ -n "$arg_title" ] && [ -n "$arg_delimiter" ]; then outstr="$outstr "; fi
  if [ -n "$arg_title" ]; then outstr="$outstr$arg_title"; fi
  if [ -n "$arg_scope" ] && [ -z "$arg_delimiter" ] && [ -n "$arg_title" ]; then outstr=" $outstr"; fi
  if [ -n "$arg_scope" ]; then outstr="($arg_scope)$outstr"; fi
  if [ -n "$arg_type" ] && [ -n "$arg_scope" ]; then outstr=" $outstr"; fi
  if [ -n "$arg_type" ]; then outstr="$arg_type$outstr"; fi
  if [ -n "$arg_icon" ]; then outstr="$arg_icon $outstr"; fi

  echo "$outstr"

  unset outstr
}

testQuickReconstitute_D008() {
  # shellcheck disable=SC2034
  test_only=true

  assertEquals "🚨 hotfix: do something" "$(reconstitute "🚨 hotfix: do something")"
  assertEquals "⚗️ wip: do something" "$(reconstitute "⚗️ wip: do something")"
  assertEquals "hotfix" "$(reconstitute "hotfix")"
  assertEquals "do something" "$(reconstitute "do something")"
  assertEquals "hotfix! Fix null ptr" "$(reconstitute "hotfix! Fix null ptr")"
  assertEquals "feat (Android): Add pinch zoom" "$(reconstitute "feat (Android): Add pinch zoom")"
  assertEquals "feat (Android) Add double tap zoom" "$(reconstitute "feat (Android) Add double tap zoom")"
  assertEquals "(Android)" "$(reconstitute "(Android)")"
  assertEquals "!" "$(reconstitute "!")"
  assertEquals ":" "$(reconstitute ":")"
}

# Load and run shUnit2.
. shunit2
