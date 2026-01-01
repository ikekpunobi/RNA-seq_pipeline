#!/bin/bash -ue
fastp         -i S1_R1.fastq.gz -I S1_R2.fastq.gz         -o S1_R1.trim.fastq.gz -O S1_R2.trim.fastq.gz         -h S1.fastp.html -j S1.fastp.json
