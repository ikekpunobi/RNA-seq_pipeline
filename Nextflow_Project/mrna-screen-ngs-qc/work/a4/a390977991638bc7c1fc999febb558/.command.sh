#!/bin/bash -ue
salmon quant -i salmon_index -l A         -1 S1_R1.trim.fastq.gz -2 S1_R2.trim.fastq.gz         -p 4         -o S1.quant         2> S1.salmon.log
