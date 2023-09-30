Tests performed with Shunit2 (https://github.com/kward/shunit2)

## Setup

If shunit2 is not already installed:

```
which shunit2
```

Then use your package manager to install shunit2.

## How does this work?

A test script contains a function that begins with the word "test". Inside 
the function is an *Assertion* style of test.

```shell
#! /bin/sh

testYearNotYet2029() {
  year=$(date '+%Y')
  assertTrue "[ ${year} -lt 2029 ]"
}

# Load and run shUnit2
. shunit2

```

At the bottom of the test script is the shunit2 shell script that runs the test.

## Run a test

To run the test script just make sure the file is executable, `chmod +x` and run
it. For example,

```shell
 $ ./my_script_test.sh
testYearNotYet2029

-e Ran 1 test.

-e OK
```

## Run all the tests

```shell
 $ make test
```
