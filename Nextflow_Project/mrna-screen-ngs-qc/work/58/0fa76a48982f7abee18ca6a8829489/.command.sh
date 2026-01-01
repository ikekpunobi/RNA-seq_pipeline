#!/bin/bash -ue
salmon quant -i salmon_index -l A         -1 S3_R1.trim.fastq.gz -2 S3_R2.trim.fastq.gz         -p 4         -o S3.quant         2> S3.salmon.log
