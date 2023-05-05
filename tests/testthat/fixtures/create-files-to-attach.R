library(graphics)

png(
  filename = testthat::test_path("fixtures", "volcano.png"),
  width = 200,
  height = 200
)
filled.contour(volcano, color.palette = terrain.colors, asp = 1)
dev.off()

cat("testing", file = testthat::test_path("fixtures", "test.ini"))
