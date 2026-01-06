#!/bin/bash -ue
set -euo pipefail

command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v md5  >/dev/null 2>&1 || { echo "md5 is required (macOS has this by default)" >&2; exit 1; }

tsv=$(curl -fsSL "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=ERR1860765&result=read_run&fields=run_accession,library_layout,fastq_ftp,fastq_md5&format=tsv")
line=$(printf "%s\n" "$tsv" | sed -n '2p')
[ -n "$line" ] || { echo "ENA returned no data for run: ERR1860765" >&2; exit 1; }

layout=$(printf "%s" "$line" | cut -f2)
echo "$layout" > layout.txt

fastq_ftp=$(printf "%s" "$line" | cut -f3)
fastq_md5=$(printf "%s" "$line" | cut -f4)

IFS=';' read -r fq1 fq2 <<< "$fastq_ftp"
IFS=';' read -r md51 md52 <<< "$fastq_md5"

url1="https://$fq1"
echo "Downloading $url1" >&2
curl -fL "$url1" -o ERR1860765_1.fastq.gz

if [ "$layout" = "PAIRED" ]; then
  url2="https://$fq2"
  echo "Downloading $url2" >&2
  curl -fL "$url2" -o ERR1860765_2.fastq.gz
else
  : > ERR1860765_2.fastq.gz
fi

if [ -n "${md51:-}" ]; then
  got=$(md5 -q ERR1860765_1.fastq.gz)
  [ "$got" = "$md51" ] || { echo "MD5 mismatch for ERR1860765_1.fastq.gz" >&2; exit 1; }
fi

if [ "$layout" = "PAIRED" ] && [ -n "${md52:-}" ]; then
  got=$(md5 -q ERR1860765_2.fastq.gz)
  [ "$got" = "$md52" ] || { echo "MD5 mismatch for ERR1860765_2.fastq.gz" >&2; exit 1; }
fi
