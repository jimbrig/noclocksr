
#  ------------------------------------------------------------------------
#
# Title : Package Configuration Setup
#    By : Jimmy Briggs
#  Date : 2024-08-09
#
#  ------------------------------------------------------------------------


# library -----------------------------------------------------------------

require(config)
require(httr2)
require(pkgload)
require(fs)
require(yaml)

pkgload::load_all()

# variables ---------------------------------------------------------------
encryption_key_name <- "NOCLOCKS_ENCRYPTION_KEY"
cfg_dir <- "inst/config"
cfg_file <- "inst/config/config.yml"
cfg_file_encrypted <- "inst/config/config.encrypted.yml"
cfg_file_template <- "inst/config/config.template.yml"

fs::dir_create(cfg_dir)

# functions ---------------------------------------------------------------









