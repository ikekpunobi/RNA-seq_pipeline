process FASTP {
  tag "${sample_id}"
  publishDir "${params.outdir}/fastp", mode: 'copy'

  container "quay.io/biocontainers/fastp:0.23.4--h125f33a_4"

  input:
    tuple val(sample_id), val(construct_id), val(condition), path(read1), path(read2)

  output:
    tuple val(sample_id), val(construct_id), val(condition),
          path("${sample_id}_R1.trim.fastq.gz"),
          path("${sample_id}_R2.trim.fastq.gz"), emit: trimmed

    tuple val(sample_id),
          path("${sample_id}.fastp.html"),
          path("${sample_id}.fastp.json"), emit: reports

  script:
    if (read2) {
      """
      fastp \
        -i ${read1} -I ${read2} \
        -o ${sample_id}_R1.trim.fastq.gz -O ${sample_id}_R2.trim.fastq.gz \
        -h ${sample_id}.fastp.html -j ${sample_id}.fastp.json \
        ${params.fastp_extra}
      """
    } else {
      """
      fastp \
        -i ${read1} \
        -o ${sample_id}_R1.trim.fastq.gz \
        -h ${sample_id}.fastp.html -j ${sample_id}.fastp.json \
        ${params.fastp_extra}
      """
    }
}
