#!/bin/bash -ue
salmon quant -i salmon_index -l A         -1 S4_R1.trim.fastq.gz -2 S4_R2.trim.fastq.gz         -p 4         -o S4.quant         2> S4.salmon.log
