#!/usr/bin/env bash
# Fails if the INTERNET permission appears in the source or merged manifests.
cd "$(dirname "$0")/.." || exit 1
bad=0
if grep -q "android.permission.INTERNET" app/src/main/AndroidManifest.xml; then
  echo "FAIL: INTERNET permission in source manifest"; bad=1
fi
while IFS= read -r f; do
  if grep -q "android.permission.INTERNET" "$f"; then
    echo "FAIL: INTERNET permission in merged manifest: $f"; bad=1
  fi
done < <(find app/build -path "*merged_manifest*" -name AndroidManifest.xml 2>/dev/null)
if [ $bad -eq 0 ]; then echo "no-internet check: OK"; fi
exit $bad
