process MULTIQC {
  tag "multiqc"
  publishDir "${params.outdir}/multiqc", mode: 'copy'

  container "quay.io/biocontainers/multiqc:1.21--pyhdfd78af_0"

  input:
    // Channels of files from upstream
    tuple val(sample_id), path(fqzip), path(fqhtml)
    tuple val(sid2), path(fphp), path(fpjson)
    path salmon_logs

  output:
    path "multiqc_report.html"
    path "multiqc_data"

  script:
    """
    mkdir -p input
    cp -r . input/ || true
    multiqc -f . -o .
    """
}
