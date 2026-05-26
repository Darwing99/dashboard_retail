# =============================================================================
# MODULES/MOD_MODELO.R - MÓDULO TAB F4: MODELADO
# =============================================================================

mod_modelo_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2(icon("brain"), " Modelado (Random Forest)"),
    br(),
    
    fluidRow(
      shinydashboard::box(
        title       = "Resumen del Modelo",
        status      = "primary",
        solidHeader = TRUE,
        width       = 12,
        verbatimTextOutput(ns("resumen_modelo"))
      )
    ),
    
    fluidRow(
      shinydashboard::box(
        title       = "Importancia de Variables",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_importancia"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Distribución de Clases",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_clases"), height = "400px")
      )
    )
  )
}

mod_modelo_server <- function(id, modelo_rf, train_data, test_data, conf_matrix) {
  moduleServer(id, function(input, output, session) {
    
    output$resumen_modelo <- renderPrint({
      cat("RANDOM FOREST - RESUMEN DEL MODELO\n")
      cat("===================================\n\n")
      cat("Objetivo: Predecir si cliente está Activo o En_Riesgo\n")
      cat("Base: RFM (Recencia, Frecuencia, Monetario)\n\n")
      
      cat("VARIABLES PREDICTORAS:\n")
      cat("  • Recencia (días desde última compra)\n")
      cat("  • Frecuencia (número de compras)\n")
      cat("  • Monetario (valor total gastado)\n")
      cat("  • R_Score, F_Score, M_Score (quintiles)\n\n")
      
      cat("PARÁMETROS DEL MODELO:\n")
      cat("  Número de árboles (ntree):", modelo_rf$ntree, "\n")
      cat("  Variables por split (mtry):", modelo_rf$mtry, "\n")
      cat("  Seed:", 123, "(reproducibilidad)\n\n")
      
      cat("DATOS DE ENTRENAMIENTO:\n")
      cat("  Train:", nrow(train_data), "registros (75%)\n")
      cat("  Test:", nrow(test_data), "registros (25%)\n\n")
      
      cat("DESEMPEÑO OOB:\n")
      cat("  Error rate (OOB):",
          round(modelo_rf$err.rate[modelo_rf$ntree, "OOB"] * 100, 2), "%\n\n")
      
      cat("MATRIZ DE CONFUSIÓN (Test):\n")
      print(conf_matrix$table)
    })
    
    output$plot_importancia <- renderPlotly({
      plot_importancia_modelo(modelo_rf)
    })
    
    output$plot_clases <- renderPlotly({
      plot_distribucion_clases(train_data, test_data)
    })
    
  })
}
