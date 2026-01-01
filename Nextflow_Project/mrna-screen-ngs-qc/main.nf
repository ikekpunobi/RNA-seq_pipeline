#!/usr/bin/env nextflow
nextflow.enable.dsl=2
include { FASTQC }        from './modules/fastqc.nf'
include { FASTP }         from './modules/fastp.nf'
include { SALMON_INDEX }  from './modules/salmon_index.nf'
include { SALMON_QUANT }  from './modules/salmon_quant.nf'
include { MULTIQC }       from './modules/multiqc.nf'
workflow {
  Channel
    .fromPath(params.samplesheet)
    .ifEmpty { error "Samplesheet not found: ${params.samplesheet}" }
    .set { samplesheet_file }

  // Parse CSV into a channel of sample records
  samples_ch = samplesheet_file
    .splitCsv(header: true)
    .map { row ->
      def sid = row.sample_id
      def r1  = file(row.fastq_1)
      def r2  = row.fastq_2 ? file(row.fastq_2) : null
      tuple(sid, row.construct_id, row.condition, r1, r2)
    }

  // QC raw reads
  fastqc_raw = FASTQC(samples_ch)

  // Trim/filter
  fp  = FASTP(samples_ch)

  // Build Salmon index (choose one path)
  def index_ch
  if (params.salmon_index) {
    index_ch = Channel.value(file(params.salmon_index))
  } else if (params.transcriptome_fasta) {
    index_ch = SALMON_INDEX(Channel.value(file(params.transcriptome_fasta))).index
  } else {
    error "Provide either --salmon_index or --transcriptome_fasta"
  }  

  // Quantification
  sal = SALMON_QUANT(fp.trimmed, index_ch)

  // MultiQC (collects FastQC + fastp + salmon logs)
  MULTIQC(fastqc_raw.out, fp.reports, sal.logs)

  // Publish results
  println "Done. See: ${params.outdir}"
}
