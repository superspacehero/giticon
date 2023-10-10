#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"
giticon_rc="${PROJECT_ROOT}/.giticon.rc"
commit_types_csv="${PROJECT_ROOT}/commit_types.csv"

# Utils
setUpOutputDirs(){
  original_pwd="${PWD}"
  OUTPUT_DIR="${SHUNIT_TMPDIR}/output"
  mkdir "${OUTPUT_DIR}"
}

setUp() {

  setUpOutputDirs

  temp_dir="$SHUNIT_TMPDIR/shellLocation_test"
  temp_commit_sh="${temp_dir}/commit.sh"
  temp_giticon_rc="${temp_dir}/.giticon.rc"
  temp_commit_types_csv="${temp_dir}/commit_type.csv"

  mkdir "$temp_dir"
  cp "$commit_sh" "$temp_commit_sh"
  cp "$giticon_rc" "$temp_giticon_rc"
  cp "$commit_types_csv" "$temp_commit_types_csv"

  cd "$temp_dir" || exit 2
}

tearDown() {
  cd "$original_pwd" || cd ~ || exit 2
  rm -fr "${temp_dir}"
}


testExecuteCommitN_H001() {
  # Run in the temporary directory
  echo "EXECUTE_COMMIT=\"N\"" >> "${temp_giticon_rc}"

  actual="$("${temp_dir}"/commit.sh --dry-run --type feat "Block git commit")"
  expected="git commit --dry-run -m \"✨ feat: Block git commit\""

  assertEquals "$expected" "$actual"
}

# Load and run shUnit2.
. shunit2
