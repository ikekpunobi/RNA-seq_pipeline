#!/bin/bash -ue
fastp         -i S4_R1.fastq.gz -I S4_R2.fastq.gz         -o S4_R1.trim.fastq.gz -O S4_R2.trim.fastq.gz         -h S4.fastp.html -j S4.fastp.json         --length_required 5 --qualified_quality_phred 10 --unqualified_percent_limit 60 --n_base_limit 10
