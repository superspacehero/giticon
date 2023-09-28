test:
	./_ready_for_testing.sh

	# A. Configuration and Settings
	./A001_rcNotFound_test.sh
	./A002_activeTable_test.sh

	# B. Simple Flags
	./B001_help_param_test.sh
	./B002_invalid_params_test.sh
	./B003_show_types_param_test.sh
	./B004_version_param_test.sh
	./B005_breaking_param_test.sh

	# C. Flags and Parameters
	./C001_type_flag_and_param_test.sh

	# D. Args
	./D001_body_and_end_args_test.sh
	./D002_body_arg_test.sh
	./D003_end_arg_test.sh
	./D004_title_and_body_args_test.sh
	./D005_title_and_end_args_test.sh
	./D006_title_arg_test.sh
	./D007_title_body_and_end_args_test.sh
	./D008_parse_title_arg_test.sh
#
#	# E. Args and Prompting
#
#	# F. Flags and Args
#	./E001_message_flag_and_arg_test.sh
#	./E002_message_flag_prevents_message_prompt_test.sh
#
#	# G. Flags and Prompts
#	./F001_breaking_and_prompt_test.sh
#
#	# M. Miscellaneous

	# U. Utilities and Helpers
	./U001_set_commit_variables_test.sh