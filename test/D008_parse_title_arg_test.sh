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

set_all_combinations() {
  # Needs to be properly formatted;
  # squeezed and no emoji tested elsewhere
  all_combinations="🚨 hotfix: do something
⚗️ wip: do something
hotfix
do something
hotfix! Fix null ptr
feat (Android): Add pinch zoom
feat (Android) Add double tap zoom
(ARM) Recode to avoid context switch
! Fix incorrect use of API
(Android)
!
:"
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

testParseQuickRoundTrip_D008() {
  # shellcheck disable=SC2034
  test_only=true

  set_all_combinations

  echo "$all_combinations" | while IFS= read -r test_arg_1; do
    assertEquals "$test_arg_1" "$(reconstitute "${test_arg_1}")"
  done
}

testParseFullRoundTrip_D008() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  set_all_combinations

  echo "$all_combinations" | while IFS= read -r test_arg_1; do

    run_init

    temp_sq=$SQUEEZE_MESSAGE
    temp_em=$ADD_EMOJI
    SQUEEZE_MESSAGE="n"
    ADD_EMOJI="n"

    run_stage_A_1 "${test_arg_1}"
    run_stage_A_2
    run_stage_A_3
    run_stage_B
    run_stage_C

    actual="$git_commit_string"
    expected="git commit -m \"$test_arg_1\""

    SQUEEZE_MESSAGE=$temp_sq
    ADD_EMOJI=$temp_em
    unset temp_sq temp_em

    assertEquals "$expected" "$actual"
  done
}


# Load and run shUnit2.
. shunit2
