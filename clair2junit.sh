#!/bin/bash
# (c) 2019 by Daniel 'f0o' Preussker <f0o@devilcode.org>
# GPLv3

tuples=$(jq '.vulnerabilities[] | [.vulnerability, .featurename, .featureversion, .link, .description]' -c -M -S | tr -d '[]"' | tr , " ")
nt=$(wc -l <<<"$tuples")

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo "<testsuites id=\"clair.scanners\" name=\"Clair Scanners\" tests=\"${nt}\" failures=\"${nt}\" time=\"0.001\">"
echo "   <testsuite id=\"clair.scanner\" name=\"Clair Scanner\" tests=\"${nt}\" failures=\"${nt}\" time=\"0.001\">"
while read line; do
 short=$(cut -d " " -f 1 <<<"$line")
 pkg=$(cut -d " " -f 2 <<<"$line")
 ver=$(cut -d " " -f 3 <<<"$line")
 if [[ -n "$short" ]] && [[ -n "$pkg" ]] && [[ -n "$ver" ]]; then
  link=$(cut -d " " -f 4 <<<"$line")
  desc=$(cut -d " " -f 5- <<<"$line")
  id=$(tr " " . <<<"$short $pkg $ver")
  echo "      <testcase id=\"$id\" name=\"$short $pkg $ver\" time=\"0.001\">"
  echo "         <failure message=\"See $short\" type=\"ERROR\">"
  (
   echo "Package $pkg Version $ver is Vulnerable to $short."
   echo
   echo "$desc"
   echo
   echo "See $link for more details."
  ) | fold -w 80 -s
  echo "         </failure>"
  echo "      </testcase>"
 fi
done <<<"$tuples"
echo "   </testsuite>"
echo "</testsuites>"
