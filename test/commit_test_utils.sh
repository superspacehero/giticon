#!/bin/sh

export test_only

debug_this=true

if [ -z "$test_only" ]; then
  true
fi

show_Stage_A_vars() {
  echo "Stage A Variables"
  echo "       is_flag_help: $is_flag_help"
  echo "   is_flag_breaking: $is_flag_breaking"
  echo " is_flag_show_types: $is_flag_show_types"
  echo "    is_flag_version: $is_flag_version"
  echo "    is_flag_message: $is_flag_message"
  echo "       flag_message: $flag_message"
  echo "      is_flag_scope: $is_flag_scope"
  echo "         flag_scope: $flag_scope"
  echo "       is_flag_type: $is_flag_type"
  echo "          flag_type: $flag_type"
  echo "          arg_title: $arg_title"
  echo "          arg_scope: $arg_scope"
  echo "           arg_type: $arg_type"
  echo "      arg_delimiter: $arg_delimiter"
  echo "           arg_body: $arg_body"
  echo "            arg_end: $arg_end"
  echo "  git_commit_params: $git_commit_params"
  echo "  bad_commit_params: $bad_commit_params"
}

show_Stage_B_vars() {
  echo "Stage B Variables"
  echo " icon: $options_icon"
  echo " type: $options_type"
  echo "scope: $options_scope"
  echo "  del: $options_delimiter"
  echo " desc: $message_title"
  echo " body: $message_body"
  echo "  end: $message_end"
  echo "  git: $git_commit_params"
}