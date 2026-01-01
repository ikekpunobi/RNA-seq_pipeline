#!/bin/bash -ue
fastp         -i S1_R1.fastq.gz -I S1_R2.fastq.gz         -o S1_R1.trim.fastq.gz -O S1_R2.trim.fastq.gz         -h S1.fastp.html -j S1.fastp.json         --length_required 5 --qualified_quality_phred 10 --unqualified_percent_limit 60 --n_base_limit 10
