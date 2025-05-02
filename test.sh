#!/usr/bin/env bash
# A very simple “test”: run main.sh and check output
OUTPUT=$(./main.sh)
if [[ "$OUTPUT" != "Hello, World!" ]]; then
  echo "Default Test failed: got '$OUTPUT'"
  exit 1
fi
echo "Default Test passed"

OUTPUT=$(./main.sh test)
if [[ "$OUTPUT" != "Hello, test!" ]]; then
  echo "Passed Arg Test failed: got '$OUTPUT'"
  exit 1
fi
echo "Passed Arg Test passed"

