process FASTQC {
  tag "${sample_id}"
  publishDir "${params.outdir}/fastqc_raw", mode: 'copy'

  container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

  input:
    tuple val(sample_id), val(construct_id), val(condition), 
    path(read1), 
    path(read2) optional true

  output:
    tuple val(sample_id), path("*_fastqc.zip"), path("*_fastqc.html"), emit: out

  script:
    if (read2) {
      """
      fastqc -t ${task.cpus} ${read1} ${read2} -o .
      """
    }
    else {
      """
      fastqc -t ${task.cpus} ${read1} -o .
      """
    }
}
