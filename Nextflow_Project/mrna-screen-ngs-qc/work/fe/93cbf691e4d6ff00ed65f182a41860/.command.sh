#!/bin/bash -ue
fastp         -i S4_R1.fastq.gz -I S4_R2.fastq.gz         -o S4_R1.trim.fastq.gz -O S4_R2.trim.fastq.gz         -h S4.fastp.html -j S4.fastp.json
