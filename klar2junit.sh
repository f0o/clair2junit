#!/bin/bash
# (c) 2020 by Daniel 'f0o' Preussker <f0o@devilcode.org>
# GPLv3
input=$(cat)
severities=$(jq '.Vulnerabilities | keys' -c -M -S <<<"$input" | tr -d '[]"' | tr , " ")
mkdir -p output
x=0
for severity in $severities; do
 echo Parsing Severity $severity
 (
  vulnerabilities=$(jq ".Vulnerabilities.${severity}[] | [.Name, .FeatureName, .FeatureVersion, .Link, .Description]" -c -M -S <<<"$input" | tr -d '[]"' | tr , " ")
  nv=$(wc -l <<<"$vulnerabilities")
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
  echo "<testsuites id=\"clair.scanners.${severity}\" name=\"Clair Scanners ${severity}\" tests=\"${nv}\" failures=\"${nv}\" time=\"0.001\">"
  echo "   <testsuite id=\"clair.scanner\" name=\"Clair Scanner\" tests=\"${nv}\" failures=\"${nv}\" time=\"0.001\">"
  while read line; do
   short=$(cut -d " " -f 1 <<<"$line")
   pkg=$(cut -d " " -f 2 <<<"$line")
   ver=$(cut -d " " -f 3 <<<"$line" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
   if [[ -n "$short" ]] && [[ -n "$pkg" ]] && [[ -n "$ver" ]]; then
    link=$(cut -d " " -f 4 <<<"$line")
    desc=$(cut -d " " -f 5- <<<"$line" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
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
  done <<<"$vulnerabilities"
  echo "   </testsuite>"
  echo "</testsuites>"
 ) > output/$severity.xml
 x=$((x+1))
done
exit $x
