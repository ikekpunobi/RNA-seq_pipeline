process SALMON_INDEX {
  tag "salmon_index"
  publishDir "${params.outdir}/salmon_index", mode: 'copy'

  container "quay.io/biocontainers/salmon:1.10.2--hecfa306_1"

  input:
    path transcriptome

  output:
    path "salmon_index", emit: index

  script:
    """
    salmon index -t ${transcriptome} -i salmon_index
    """
}
