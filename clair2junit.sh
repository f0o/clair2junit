#!/bin/bash
# (c) 2019 by Daniel 'f0o' Preussker <f0o@devilcode.org>
# GPLv3

tuples=$(jq '.vulnerabilities[] | [.vulnerability, .featurename, .featureversion]' -c -M -S | tr -d '[]"' | tr , " ")
nt=$(wc -l <<<"$tuples")

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo "<testsuites id=\"clair.scanners\" name=\"Clair Scanners\" tests=\"${nt}\" failures=\"${nt}\" time=\"0.001\">"
echo "   <testsuite id=\"clair.scanner\" name=\"Clair Scanner\" tests=\"${nt}\" failures=\"${nt}\" time=\"0.001\">"
while read line; do
 id=$(tr " " . <<<"$line")
 name="$line"
 short=$(cut -d " " -f 1 <<<"$line")
 pkg=$(cut -d " " -f 2 <<<"$line")
 ver=$(cut -d " " -f 3 <<<"$line")
 echo "      <testcase id=\"$id\" name=\"$name\" time=\"0.001\">"
 echo "         <failure message=\"See $short\" type=\"ERROR\">"
 echo "            Package $pkg Version $ver is vulnerable to $short"
 echo "         </failure>"
 echo "      </testcase>"
done <<<"$tuples"
echo "   </testsuite>"
echo "</testsuites>"
