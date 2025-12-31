process FASTQC {
  tag "${sample_id}"
  publishDir "${params.outdir}/fastqc_raw", mode: 'copy'

  container "biocontainers/fastqc:v0.12.1_cv8"

  input:
    tuple val(sample_id), val(construct_id), val(condition), path(read1), path(read2)

  output:
    tuple val(sample_id), path("*_fastqc.zip"), path("*_fastqc.html"), emit: out

  script:
    def reads = read2 ? "${read1} ${read2}" : "${read1}"
    """
    fastqc -t ${task.cpus} ${reads}
    """
}
