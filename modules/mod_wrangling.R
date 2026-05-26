# =============================================================================
# MODULES/MOD_WRANGLING.R - MÓDULO TAB F3: WRANGLING
# =============================================================================

mod_wrangling_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2(icon("wrench"), " Data Wrangling (Limpieza)"),
    br(),
    
    fluidRow(
      shinydashboard::box(
        title       = "Información de Cancelaciones",
        status      = "warning",
        solidHeader = TRUE,
        width       = 6,
        verbatimTextOutput(ns("cancel_info"))
      ),
      shinydashboard::box(
        title       = "Información Limpieza",
        status      = "info",
        solidHeader = TRUE,
        width       = 6,
        verbatimTextOutput(ns("wrangle_resumen"))
      )
    ),
    
    fluidRow(
      shinydashboard::box(
        title       = "Distribución Revenue (sin outliers)",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_revenue_dist"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Segmentos de Precio",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_seg_precio"), height = "400px")
      )
    )
  )
}

mod_wrangling_server <- function(id, retail_raw, retail_clean) {
  moduleServer(id, function(input, output, session) {
    
    output$cancel_info <- renderPrint({
      nc <- sum(grepl("^C", retail_raw$Invoice))
      cat("INFORMACIÓN DE CANCELACIONES\n")
      cat("=============================\n\n")
      cat("Total cancelaciones: ", nc, "\n", sep = "")
      cat("Porcentaje: ", round(nc / nrow(retail_raw) * 100, 2), "%\n", sep = "")
      cat("(excluidas del análisis)\n")
    })
    
    output$wrangle_resumen <- renderPrint({
      raw_n    <- nrow(retail_raw)
      clean_n  <- nrow(retail_clean)
      removidos <- raw_n - clean_n
      
      cat("PROCESO DE LIMPIEZA (DATA WRANGLING)\n")
      cat("====================================\n\n")
      cat("Registros iniciales (raw):", raw_n, "\n")
      cat("Registros finales (clean):", clean_n, "\n")
      cat("Registros removidos:", removidos,
          "(", round(removidos / raw_n * 100, 2), "%)\n\n")
      
      cat("CRITERIOS DE LIMPIEZA:\n")
      cat("  Eliminar cancelaciones (facturas que empiezan con 'C')\n")
      cat("  Mantener solo Quantity > 0\n")
      cat("  Mantener solo Price > 0\n")
      cat("  Eliminar CustomerID vacíos\n")
      cat("  Eliminar StockCode vacíos\n")
      cat("  Remover duplicados exactos\n\n")
      
      cat("ENRIQUECIMIENTO:\n")
      cat("  Parse de fechas (year, month, quarter, day_of_week, hour)\n")
      cat("  Cálculo Revenue = Quantity × Price\n")
      cat("  Segmentación de precio (5 niveles)\n")
    })
    
    output$plot_revenue_dist <- renderPlotly({
      plot_revenue_dist(retail_clean)
    })
    
    output$plot_seg_precio <- renderPlotly({
      plot_segmento_precio(retail_clean)
    })
    
  })
}
