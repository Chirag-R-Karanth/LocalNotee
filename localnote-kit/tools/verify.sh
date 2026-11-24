#!/usr/bin/env bash
# Full verification. Must print "VERIFY: PASS" to count as success.
cd "$(dirname "$0")/.." || exit 1
fail=0
echo "== source manifest check =="
bash tools/check_no_internet.sh || fail=1
echo "== build =="
./gradlew --console=plain :app:assembleDebug || fail=1
echo "== unit tests =="
./gradlew --console=plain :app:testDebugUnitTest || fail=1
echo "== lint =="
./gradlew --console=plain :app:lintDebug || fail=1
echo "== merged manifest check =="
bash tools/check_no_internet.sh || fail=1
if [ $fail -eq 0 ]; then echo "VERIFY: PASS"; else echo "VERIFY: FAIL"; exit 1; fi
