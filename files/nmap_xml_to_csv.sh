#!/bin/bash

INPUT_XML="$1"
OUTPUT_CSV="$2"

if [[ -z "$INPUT_XML" || -z "$OUTPUT_CSV" ]]; then
  echo "Use: $0 input_file.xml output_file.csv"
  exit 1
fi

if ! command -v xmlstarlet &>/dev/null; then
  echo "Missing xmlstarlet. Install: sudo apt install xmlstarlet"
  exit 1
fi

TMP_XML=$(mktemp)
grep -vE '<!--.*-->' "$INPUT_XML" > "$TMP_XML"

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
  -n "$TMP_XML" >> "$OUTPUT_CSV"

rm "$TMP_XML"

echo "CSV file saved as: $OUTPUT_CSV"