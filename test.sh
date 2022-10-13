#!/usr/bin/env bash

# Usage: test.sh [testname]

set -e
shopt -s failglob

trap "echo aborted; exit;" SIGINT SIGTERM

if [ -z "$1" ] ; then
    # test.sh; run all .vd/.vdj/.vdx in tests/
    TESTS="tests/*.vd*"
else
    # test.sh testname; run tests/testname.vd
    TESTS=tests/$1.vd*
fi

for i in $TESTS ; do
    echo "--- $i"
    outbase=${i##tests/}
    if [ "${i%-nosave.vd*}-nosave" == "${i%.vd*}" ];
    then
        echo "$1"
    else
        for goldfn in tests/golden/${outbase%.vd*}.*; do
            PYTHONPATH=. vdsql --confirm-overwrite=False --play "$i" --batch --output "$goldfn" --config tests/.visidatarc --visidata-dir tests/.visidata
            echo "save: $goldfn"
        done
    fi
done

echo '=== git diffs for BUILD FAILURE ==='
git --no-pager diff --numstat tests/
git --no-pager diff --exit-code tests/
echo '=============================================='
