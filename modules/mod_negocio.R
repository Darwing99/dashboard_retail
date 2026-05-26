# =============================================================================
# MODULES/MOD_NEGOCIO.R - MÓDULO TAB F1: NEGOCIO
# =============================================================================

mod_negocio_ui <- function(id) {
  ns <- NS(id)

  tagList(
    h2(icon("briefcase"), " Análisis de Negocio"),
    br(),

    # --- Ventas en el tiempo ---
    fluidRow(
      shinydashboard::box(
        title       = "Ventas a lo largo del tiempo",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        plotlyOutput(ns("plot_ventas_mes"), height = "400px")
      )
    ),

    # --- Países y resumen general ---
    fluidRow(
      shinydashboard::box(
        title       = "Top 10 Países por Revenue",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_top_paises"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Información General",
        status      = "warning",
        solidHeader = TRUE,
        width       = 6,
        verbatimTextOutput(ns("info_general"))
      )
    ),

    # --- Nuevos gráficos ---
    fluidRow(
      shinydashboard::box(
        title       = "Revenue por Trimestre (comparativo anual)",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_revenue_trimestral"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Revenue por Día de la Semana",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_ventas_dia_semana"), height = "400px")
      )
    ),

    fluidRow(
      shinydashboard::box(
        title       = "Top 10 Productos más Vendidos",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        plotlyOutput(ns("plot_top_productos"), height = "420px")
      )
    )
  )
}

mod_negocio_server <- function(id, retail_clean) {
  moduleServer(id, function(input, output, session) {

    output$plot_ventas_mes <- renderPlotly({
      plot_ventas_mes(retail_clean)
    })

    output$plot_top_paises <- renderPlotly({
      plot_top_paises(retail_clean, top_n = 10)
    })

    output$info_general <- renderPrint({
      cat("INFORMACIÓN GENERAL DEL DATASET\n")
      cat("================================\n\n")
      cat("Período de datos:\n")
      cat("  Desde:", format(min(retail_clean$Fecha), "%d/%m/%Y"), "\n")
      cat("  Hasta:", format(max(retail_clean$Fecha), "%d/%m/%Y"), "\n")
      cat("  Duración:", as.numeric(difftime(
        max(retail_clean$Fecha),
        min(retail_clean$Fecha),
        units = "days"
      )), "días\n\n")

      cat("Clientes únicos:", n_distinct(retail_clean$CustomerID), "\n")
      cat("Transacciones:", nrow(retail_clean), "\n")
      cat("Países:", n_distinct(retail_clean$Country), "\n")
      cat("Productos (SKU):", n_distinct(retail_clean$StockCode), "\n\n")

      cat("Revenue promedio por transacción: £",
          round(mean(retail_clean$Revenue, na.rm = TRUE), 2), "\n")
      cat("Revenue mediano:",
          fmt_gbp(median(retail_clean$Revenue, na.rm = TRUE)), "\n")
      cat("Cantidad promedio por transacción:",
          round(mean(retail_clean$Quantity, na.rm = TRUE), 2), "\n")
    })

    output$plot_revenue_trimestral <- renderPlotly({
      plot_revenue_trimestral(retail_clean)
    })

    output$plot_ventas_dia_semana <- renderPlotly({
      plot_ventas_dia_semana(retail_clean)
    })

    output$plot_top_productos <- renderPlotly({
      plot_top_productos(retail_clean, top_n = 10)
    })

  })
}
