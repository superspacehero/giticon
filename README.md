# giticon

## A gitmoji-like system for generating commit titles

### Setup

Add **giticontypes.csv** and **.giticon.rc** to the root of your repository. **commit.sh** can optionally be symbolically linked to */usr/local/bin* to allow the command to be run from anywhere.

If a repository has those two files, or **.giticon.rc** is given a different .csv file to point towards, the script will use that project's given commit types. Built-in ones are also available for any other repository.

### Usage

At minimum, this is valid: `$ path/to/commit.sh`. Setting up the symbolic link using `$ sudo ln -s path/to/commit.sh /usr/local/bin/commit` will allow you to simply run it as `$ commit`. Further references assume you have done this, but you can adjust them as necessary for your purposes.

#### Available Flags

`-d` or `--dry-run`: test to see what the commit would be titled if one was made.

`-a` or `--amend`: amend the last commit with the new title, rather than making a new one.

`-m` or `--message`: use the given message instead of prompting for one.

`-s` or `--scope`: use the given scope instead of prompting for one.

Any unflagged arguments are treated as the commit type. If the commit type is not found, the script will prompt for one.

**Example:**

| Command                                                      | Output                                            |
| ------------------------------------------------------------ | ------------------------------------------------- |
| $ commit -d -a -m "This is a commit message" -s "ExamplePlatform" feat | ✨ feat(ExamplePlatform): This is a commit message |
