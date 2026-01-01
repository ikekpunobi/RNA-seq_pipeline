#!/bin/bash -ue
fastqc -t 2 S3_R1.fastq.gz S3_R2.fastq.gz
