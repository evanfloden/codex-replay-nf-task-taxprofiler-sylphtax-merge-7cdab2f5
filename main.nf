nextflow.enable.dsl=2

params.data = params.data ?: '/app/data'
params.out = params.out ?: '/app/out'

process SYLPHTAX_MERGE {
  container 'quay.io/biocontainers/sylph-tax:1.2.0--pyhdfd78af_0'
  cpus 1
  memory '4 GB'
  time '1 h'
  publishDir params.out, mode: 'copy'

  input:
  path data_dir

  output:
  path 'sylph_db1_combined_reports.tsv'
  path 'versions.yml'

  script:
  """
  set -euo pipefail
  cp -a "${data_dir}"/* .
  export SYLPH_TAXONOMY_CONFIG="/tmp/config.json"
  sylph-tax merge 2613_ERR5766181_db1.sylphmpa 2612_ERR5766176_db1.sylphmpa --column relative_abundance --output sylph_db1_combined_reports.tsv
  cat <<-END_VERSIONS > versions.yml
  "NFCORE_TAXPROFILER:TAXPROFILER:STANDARDISATION_PROFILES:SYLPHTAX_MERGE":
      sylph-tax: $(sylph-tax --version)
  END_VERSIONS
  """
}

workflow {
  data_ch = Channel.value(file(params.data, checkIfExists: true))
  SYLPHTAX_MERGE(data_ch)
}
