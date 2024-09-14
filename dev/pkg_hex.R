
#  ------------------------------------------------------------------------
#
# Title : Package Hex Logo Script
#    By : Jimmy Briggs
#  Date : 2024-09-13
#
#  ------------------------------------------------------------------------


# libraries ---------------------------------------------------------------
require(magick)
require(hexSticker)
require(showtext)
require(ggplot2)

# image URLs --------------------------------------------------------------
img_base_url <- "https://cdn.brandfetch.io/noclocks.dev/"
img_symbol_url <- paste0(img_base_url, "symbol")
img_logo_url <- paste0(img_base_url, "logo")
img_gh_url <- "https://github.com/noclocks/noclocks-brand/blob/main/src/images/logos/main/noclocks-logo-circular-texturized.png?raw=true"

# download images ---------------------------------------------------------
img_symbol <- magick::image_read(img_symbol_url)
img_logo <- magick::image_read(img_logo_url)
img_gh <- magick::image_read(img_gh_url)

img_symbol |> magick::image_write("man/figures/noclocks-symbol.webp")
img_logo |> magick::image_write("man/figures/noclocks-wordmark.webp")
img_gh |> magick::image_write("man/figures/noclocks-logo.png")

# setup font(s) -----------------------------------------------------------
font_add_google("Ubuntu", "ubuntu")
showtext::showtext_auto()

# create hex logo ---------------------------------------------------------
hexSticker::sticker(
  package = "noclocksr",
  subplot = img_gh,
  url = "github.com/noclocks/noclocksr",
  filename = "man/figures/hex.png",
  p_x = 1,
  p_y = 1.5,
  p_family = "ubuntu",
  p_color = "white",
  p_size = 8,
  s_width = 0.5,
  s_height = 0.5,
  s_x = 1,
  s_y = 0.9,
  asp = 0.9,
  u_x = 1,
  u_y = 0.08,
  u_color = "#4D86D1",
  u_family = "ubuntu",
  u_size = 1.2,
  u_angle = 30,
  h_fill = "black",
  h_color = "#4D86D1"
)
