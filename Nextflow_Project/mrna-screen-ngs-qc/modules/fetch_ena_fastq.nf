process FETCH_ENA_FASTQ {
  tag "${run}"
  publishDir "${params.reads_dir}", mode: 'copy'

  // lightweight image; we'll install curl + coreutils for md5sum
  container "alpine:3.20"

  input:
    val run

  output:
    tuple val(run), val(layout),
          path("${run}_1.fastq.gz"),
          path("${run}_2.fastq.gz") optional true,
          emit: reads

  script:
    """
    set -euo pipefail
    apk add --no-cache curl coreutils

    # Query ENA filereport for this run:
    # fields: run_accession,library_layout,fastq_ftp,fastq_md5
    tsv=\$(curl -fsSL "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=run_accession,library_layout,fastq_ftp,fastq_md5&format=tsv")

    # Second line has the data (first is header)
    line=\$(printf "%s\\n" "\$tsv" | sed -n '2p')
    [ -n "\$line" ] || { echo "ENA returned no data for run: ${run}" >&2; exit 1; }

    # Parse columns (TSV)
    run_acc=\$(printf "%s" "\$line" | cut -f1)
    layout=\$(printf "%s" "\$line" | cut -f2)
    fastq_ftp=\$(printf "%s" "\$line" | cut -f3)
    fastq_md5=\$(printf "%s" "\$line" | cut -f4)

    echo "\$layout" > layout.txt

    # Split semicolon-separated lists
    IFS=';' read -r fq1 fq2 <<< "\$fastq_ftp"
    IFS=';' read -r md51 md52 <<< "\$fastq_md5"

    # ENA gives ftp host paths; download via https
    url1="https://\$fq1"
    echo "Downloading: \$url1" >&2
    curl -fL "\$url1" -o ${run}_1.fastq.gz

    if [ "\$layout" = "PAIRED" ]; then
      url2="https://\$fq2"
      echo "Downloading: \$url2" >&2
      curl -fL "\$url2" -o ${run}_2.fastq.gz
    else
      # create an empty placeholder so downstream tuple shape is consistent
      # (or you can adapt downstream to truly single-end)
      : > ${run}_2.fastq.gz
    fi

    # Verify checksums if provided
    if [ -n "\${md51:-}" ]; then
      echo "\${md51}  ${run}_1.fastq.gz" | md5sum -c -
    fi
    if [ "\$layout" = "PAIRED" ] && [ -n "\${md52:-}" ]; then
      echo "\${md52}  ${run}_2.fastq.gz" | md5sum -c -
    fi
    """
}