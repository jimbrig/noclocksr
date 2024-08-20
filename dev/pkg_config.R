
pkgload::load_all()

source("dev/cfgs.R")

cfg_init(
  cfg = base_cfg
)

cfg_d_init(
  configs = cfgs,
  merge = TRUE,
  ignore = TRUE,
  overwrite = TRUE,
  templates = TRUE,
  include_encrypted = TRUE
)

cfg_hooks_init(
  cfg_file = "inst/config/config.yml"
)

cfg_hooks_init(
  cfg_file = "inst/config/config.merged.yml"
)

