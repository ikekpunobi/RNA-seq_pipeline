process SALMON_QUANT {
  tag "${sample_id}"
  publishDir "${params.outdir}/salmon", mode: 'copy'

  container "quay.io/biocontainers/salmon:1.9.0--h7e5ed60_0"



  input:
    tuple val(sample_id), val(construct_id), val(condition), path(trim1), path(trim2)
    path salmon_index

  

  output:
    tuple val(sample_id), val(construct_id), val(condition), path("${sample_id}.quant")
    path "${sample_id}.salmon.log", emit:  logs

  
  script:
    def libtype = "A"
    if (trim2) {
      """
      salmon quant -i ${salmon_index} -l ${libtype} \
        -1 ${trim1} -2 ${trim2} \
        -p ${task.cpus} \
        -o ${sample_id}.quant \
        2> ${sample_id}.salmon.log
      """
    } else {
      """
      salmon quant -i ${salmon_index} -l ${libtype} \
        -r ${trim1} \
        -p ${task.cpus} \
        -o ${sample_id}.quant \
        2> ${sample_id}.salmon.log
      """
    }
}
