#!/bin/bash -ue
salmon quant -i salmon_index -l A         -1 S2_R1.trim.fastq.gz -2 S2_R2.trim.fastq.gz         -p 4         -o S2.quant         2> S2.salmon.log
