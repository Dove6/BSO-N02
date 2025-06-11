#!/bin/sh

curl -s -k -w "\n" -u "${ROUTEROS_USERNAME}:${ROUTEROS_PASSWORD}" "http://${ROUTEROS_HOST}/rest/ip/dhcp-server/lease" | yq -o=csv '.[].address' > ./hosts.txt

./nmap_xml_to_csv.sh ./hosts.txt /reports/report.csv

curl -s -k -w "\n" -u "${ROUTEROS_USERNAME}:${ROUTEROS_PASSWORD}" "http://${ROUTEROS_HOST}/rest/tool/e-mail/send" \
    --data '{ "to": "'"${EMAIL_RECIPIENT}"'", "subject": "Report", "body": "Hello, world!", "file": "reports/report.csv" }' \
    -H "Content-Type: application/json"
