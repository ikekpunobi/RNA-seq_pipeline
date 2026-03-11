# RNA-seq Analysis Pipeline (Nextflow + Salmon)

## Overview
This project is an end-to-end, reproducible RNA-seq analysis pipeline built using Nextflow (DSL2). It automates the process from raw sequencing data retrieval to transcript-level quantification, while enabling portability, reproducibility, and scalability.

The pipeline is designed to work seamlessly with both single-end and paired-end RNA-seq data, and can be executed locally, on HPC systems, or in the cloud using containerized environments.

NOTE: This pipeline is demonstrated using publicly available RNA-seq data from ENA. No controlled-access or sensitive data are included.
---

## Key Features
- Automated data retrieval from the European Nucleotide Archive (ENA)
- Quality control using FastQC and MultiQC
- Transcript-level quantification with Salmon
- Robust handling of single-end and paired-end libraries
- Docker support for full reproducibility
- Modular DSL2 design for easy extension and maintenance

---

## Pipeline Workflow
1. Input metadata parsing (ENA accessions, library layout, sample info)
2. FASTQ download from ENA
3. Quality control with FastQC
4. QC aggregation with MultiQC
5. Transcript quantification using Salmon
6. Structured outputs for downstream analysis (e.g., tximport / DESeq2)

---

## Requirements

### Software
- Nextflow (>= 22.x)
- Docker or Singularity/Apptainer

### Containers
All tools are run inside containers:
- FastQC
- MultiQC
- Salmon

No local installation of bioinformatics tools is required beyond Nextflow and a container engine.

---

## Input

### Sample Metadata
The pipeline expects a sample sheet (CSV or TSV) containing, at minimum:

- sample_id
- ena_run_accession
- library_layout (SINGLE or PAIRED)

Example:
```csv
sample_id,ena_run_accession,library_layout
sampleA,ERR1234567,PAIRED
sampleB,ERR1234568,SINGLE
```

### Reference Files
- Transcriptome FASTA
- Salmon index (generated beforehand or as a pipeline extension)

---

## Usage

### Run Locally with Docker
```bash
nextflow run main.nf \
  --samples samples.csv \
  --transcriptome transcripts.fa \
  -profile docker
```

### Run on HPC (example)
```bash
nextflow run main.nf -profile slurm,singularity
```

---

## Outputs

```
results/
├── fastqc/          # Per-sample FastQC reports
├── multiqc/         # Aggregated QC report
├── salmon/          # Transcript-level quantification
│   └── quant.sf
└── logs/
```

Key output file:
- quant.sf – transcript-level abundance estimates suitable for tximport and downstream differential expression analysis.

---

## Design Considerations

### Single-end vs Paired-end Handling
The pipeline explicitly handles differences between library layouts:
- Paired-end: _1 and _2 FASTQs passed to Salmon
- Single-end: only _1 FASTQ used; read2 is optional and safely ignored

This avoids brittle logic and prevents downstream failures caused by missing or empty files.

### Reproducibility
- Containerized execution
- Explicit versioning of tools
- Deterministic pipeline structure via Nextflow DSL2

---

## Extensibility
This pipeline is intentionally modular and can be extended to include:
- Salmon index generation
- DESeq2 differential expression analysis
- Metadata-driven contrasts
- Automated QC thresholding
- Pathway and gene ontology enrichment

---

## Use Cases
- Academic RNA-seq analysis
- Construct or condition comparison
- Method development and benchmarking
- Portfolio demonstration of reproducible bioinformatics workflows

---

## Author Notes
This project was developed to demonstrate production-quality bioinformatics pipeline design featuring real-world usability.

It is suitable both as a research tool and as a portfolio artifact for computational biology and bioinformatics roles.

---


