
#  ------------------------------------------------------------------------
#
# Title : noclocksr - Package Data Script
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------

usethis::use_r("pkg_data", open = FALSE)
usethis::use_r("pkg_docs", open = FALSE)

usethis::use_test("document_dataset")

# internal ----------------------------------------------------------------

usethis::use_data_raw("internal", open = FALSE)
