#!/bin/sh

INPUT_FILE="$1"
OUTPUT_CSV="$2"

if [[ -z "$INPUT_FILE" || -z "$OUTPUT_CSV" ]]; then
  echo "Usage: $0 hosts_list.txt output.csv"
  exit 1
fi

if ! command -v nmap &>/dev/null; then
  echo "nmap not found, please install it."
  exit 1
fi

if ! command -v xmlstarlet &>/dev/null; then
  echo "xmlstarlet not found, please install it."
  exit 1
fi

CLEAN_HOSTS=$(mktemp)
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$INPUT_FILE" > "$CLEAN_HOSTS"

if [[ ! -s "$CLEAN_HOSTS" ]]; then
  echo "No valid IP addresses found in input file."
  rm "$CLEAN_HOSTS"
  exit 1
fi

echo "Starting Nmap scan..."

COMMON_PORTS="21,22,23,25,53,80,111,139,143,161,443,445,465,993,995,1080,1433,1521,2049,3306,3389,5432,5900,6379,8000,8080,8443"

NSE_SCRIPTS="default,vuln,ftp-anon,http-title,smb-os-discovery,smb-vuln*"

TEMP_XML=$(mktemp)

nmap -T4 -sV -Pn -n \
  -p "$COMMON_PORTS" \
  --min-rate 300 \
  --script="$NSE_SCRIPTS" \
  --script-timeout 30s \
  -iL "$CLEAN_HOSTS" \
  -oX "$TEMP_XML"

echo "Parsing XML to CSV..."

echo "IP,Port,Protocol,State,Service Name,Product,Version,ExtraInfo,OSType,Hostname,CPEs,Script IDs,Script Outputs" > "$OUTPUT_CSV"

xmlstarlet sel -T -t \
  -m "//host[status/@state='up']/ports/port" \
  -v "ancestor::host/address[@addrtype='ipv4']/@addr" -o "," \
  -v "@portid" -o "," \
  -v "@protocol" -o "," \
  -v "state/@state" -o "," \
  -v "service/@name" -o "," \
  -v "service/@product" -o "," \
  -v "service/@version" -o "," \
  -v "service/@extrainfo" -o "," \
  -v "service/@ostype" -o "," \
  -v "service/@hostname" -o "," \
  -m "service/cpe" -v "." -o "|" -b -o "," \
  -m "script" -v "@id" -o "|" -b -o "," \
  -m "script" -v "normalize-space(@output)" -o "|" -b \
  -n "$TEMP_XML" >> "$OUTPUT_CSV"

rm "$TEMP_XML" "$CLEAN_HOSTS"

echo "Scan and parsing complete. Results saved to: $OUTPUT_CSV"
