#!/bin/bash -ue
set -euo pipefail
apk add --no-cache curl coreutils

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
curl -fL "$url1" -o ERR1860765_1.fastq.gz

if [ "$layout" = "PAIRED" ]; then
  url2="https://$fq2"
  curl -fL "$url2" -o ERR1860765_2.fastq.gz
fi

if [ -n "${md51:-}" ]; then
  echo "${md51}  ERR1860765_1.fastq.gz" | md5sum -c -
fi
if [ "$layout" = "PAIRED" ] && [ -n "${md52:-}" ]; then
  echo "${md52}  ERR1860765_2.fastq.gz" | md5sum -c -
fi
