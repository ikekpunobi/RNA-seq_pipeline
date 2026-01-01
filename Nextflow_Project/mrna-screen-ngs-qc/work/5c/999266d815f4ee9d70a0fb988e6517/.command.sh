#!/bin/bash -ue
fastp         -i S3_R1.fastq.gz -I S3_R2.fastq.gz         -o S3_R1.trim.fastq.gz -O S3_R2.trim.fastq.gz         -h S3.fastp.html -j S3.fastp.json
