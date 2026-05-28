Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")

library(rmarkdown)

rmd_file <- "c:/Users/Darwing Hernandez/Desktop/Data Science/Programacion en R/dashboard_retail/informe_proyecto.Rmd"

rmarkdown::render(
  input       = rmd_file,
  output_format = "word_document",
  output_file = "informe_proyecto.docx"
)

cat("Informe generado correctamente.\n")
