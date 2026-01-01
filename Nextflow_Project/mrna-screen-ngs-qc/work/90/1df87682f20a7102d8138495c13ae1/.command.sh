#!/bin/bash -ue
fastp         -i S2_R1.fastq.gz -I S2_R2.fastq.gz         -o S2_R1.trim.fastq.gz -O S2_R2.trim.fastq.gz         -h S2.fastp.html -j S2.fastp.json         --length_required 5 --qualified_quality_phred 10 --unqualified_percent_limit 60 --n_base_limit 10
