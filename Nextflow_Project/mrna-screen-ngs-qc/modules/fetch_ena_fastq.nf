process FETCH_ENA_FASTQ {
  tag "${run}"
  publishDir "${params.reads_dir}", mode: 'copy'

  input:
    val run

  output:
    tuple val(run), path("layout.txt"), path("${run}_1.fastq.gz"), path("${run}_2.fastq.gz"), emit: reads

  script:
    """
    set -euo pipefail

    download() {
      local url="\$1"
      local out="\$2"

      # -C - : resume partial downloads
      # --retry / --retry-all-errors : retry on transient errors/timeouts
      # --retry-delay : wait between retries
      # --speed-time/--speed-limit : fail if transfer stalls too long (then retry)
      curl -fL -C - \
        --retry 10 --retry-all-errors --retry-delay 10 \
        --speed-time 60 --speed-limit 1024 \
        "\$url" -o "\$out"
    }

    command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
    command -v md5  >/dev/null 2>&1 || { echo "md5 is required (macOS has this by default)" >&2; exit 1; }

    tsv=\$(curl -fsSL "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${run}&result=read_run&fields=run_accession,library_layout,fastq_ftp,fastq_md5&format=tsv")
    line=\$(printf "%s\\n" "\$tsv" | sed -n '2p')
    [ -n "\$line" ] || { echo "ENA returned no data for run: ${run}" >&2; exit 1; }

    layout=\$(printf "%s" "\$line" | cut -f2)
    echo "\$layout" > layout.txt

    fastq_ftp=\$(printf "%s" "\$line" | cut -f3)
    fastq_md5=\$(printf "%s" "\$line" | cut -f4)

    IFS=';' read -r fq1 fq2 <<< "\$fastq_ftp"
    IFS=';' read -r md51 md52 <<< "\$fastq_md5"

    url1="https://\$fq1"
    echo "Downloading \$url1" >&2
    download "\$url1" "${run}_1.fastq.gz"

    if [ "\$layout" = "PAIRED" ]; then
      url2="https://\$fq2"
      echo "Downloading \$url2" >&2
      download "\$url2" "${run}_2.fastq.gz"
    else
      : > ${run}_2.fastq.gz
    fi

    if [ -n "\${md51:-}" ]; then
      got=\$(md5 -q ${run}_1.fastq.gz)
      [ "\$got" = "\$md51" ] || { echo "MD5 mismatch for ${run}_1.fastq.gz" >&2; exit 1; }
    fi

    if [ "\$layout" = "PAIRED" ] && [ -n "\${md52:-}" ]; then
      got=\$(md5 -q ${run}_2.fastq.gz)
      [ "\$got" = "\$md52" ] || { echo "MD5 mismatch for ${run}_2.fastq.gz" >&2; exit 1; }
    fi
    """
}