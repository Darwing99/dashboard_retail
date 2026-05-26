# =============================================================================
# MODULES/MOD_EDA.R - MÓDULO TAB F2: EDA
# =============================================================================

mod_eda_ui <- function(id) {
  ns <- NS(id)

  tagList(
    h2(icon("chart-bar"), " Exploración de Datos (EDA)"),
    br(),

    # --- Resumen estadístico ---
    fluidRow(
      shinydashboard::box(
        title       = "Resumen Estadístico",
        status      = "success",
        solidHeader = TRUE,
        width       = 12,
        verbatimTextOutput(ns("eda_resumen"))
      )
    ),

    # --- Distribuciones originales ---
    fluidRow(
      shinydashboard::box(
        title       = "Distribución Revenue por Transacción",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_revenue_eda"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Distribución de Unidades por Transacción",
        status      = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_dist_quantity"), height = "400px")
      )
    ),

    # --- Heatmap de actividad ---
    fluidRow(
      shinydashboard::box(
        title       = "Mapa de Calor: Actividad por Hora y Día",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        p("Intensidad de transacciones según hora y día de la semana."),
        plotlyOutput(ns("plot_heatmap_hora_dia"), height = "450px")
      )
    ),

    # --- Revenue por segmento en el tiempo y top países ---
    fluidRow(
      shinydashboard::box(
        title       = "Revenue por Segmento de Precio en el Tiempo",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_revenue_segmento_tiempo"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Top 10 Países por Revenue",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        verbatimTextOutput(ns("eda_paises"))
      )
    )
  )
}

mod_eda_server <- function(id, retail_clean) {
  moduleServer(id, function(input, output, session) {

    output$eda_resumen <- renderPrint({
      cat("RESUMEN ESTADÍSTICO DEL DATASET LIMPIO\n")
      cat("======================================\n\n")
      cat("Total registros:", nrow(retail_clean), "\n")
      cat("Total clientes únicos:", n_distinct(retail_clean$CustomerID), "\n")
      cat("Período:", format(min(retail_clean$Fecha), "%b %Y"),
          "a", format(max(retail_clean$Fecha), "%b %Y"), "\n\n")

      cat("REVENUE (£):\n")
      cat("  Mínimo:", fmt_gbp(min(retail_clean$Revenue, na.rm = TRUE)), "\n")
      cat("  Máximo:", fmt_gbp(max(retail_clean$Revenue, na.rm = TRUE)), "\n")
      cat("  Promedio:", fmt_gbp(mean(retail_clean$Revenue, na.rm = TRUE)), "\n")
      cat("  Mediana:", fmt_gbp(median(retail_clean$Revenue, na.rm = TRUE)), "\n")
      cat("  Total:", fmt_gbp(sum(retail_clean$Revenue, na.rm = TRUE)), "\n\n")

      cat("CANTIDAD:\n")
      cat("  Mínimo:", min(retail_clean$Quantity, na.rm = TRUE), "\n")
      cat("  Máximo:", max(retail_clean$Quantity, na.rm = TRUE), "\n")
      cat("  Promedio:", round(mean(retail_clean$Quantity, na.rm = TRUE), 2), "\n\n")

      cat("PRECIO (£):\n")
      cat("  Mínimo: £", round(min(retail_clean$Price, na.rm = TRUE), 2), "\n")
      cat("  Máximo: £", round(max(retail_clean$Price, na.rm = TRUE), 2), "\n")
      cat("  Promedio: £", round(mean(retail_clean$Price, na.rm = TRUE), 2), "\n")
    })

    output$plot_revenue_eda <- renderPlotly({
      plot_revenue_dist(retail_clean)
    })

    output$plot_dist_quantity <- renderPlotly({
      plot_dist_quantity(retail_clean)
    })

    output$plot_heatmap_hora_dia <- renderPlotly({
      plot_heatmap_hora_dia(retail_clean)
    })

    output$plot_revenue_segmento_tiempo <- renderPlotly({
      plot_revenue_segmento_tiempo(retail_clean)
    })

    output$eda_paises <- renderPrint({
      paises_top <- retail_clean |>
        dplyr::group_by(Country) |>
        dplyr::summarise(
          N        = dplyr::n(),
          Revenue  = sum(Revenue, na.rm = TRUE),
          Clientes = dplyr::n_distinct(CustomerID),
          .groups  = "drop"
        ) |>
        dplyr::arrange(dplyr::desc(Revenue)) |>
        dplyr::slice(1:10)

      cat("TOP 10 PAÍSES POR REVENUE\n")
      cat("==========================\n\n")
      for (i in seq_len(nrow(paises_top))) {
        cat(i, ".", paises_top$Country[i], "\n")
        cat("   Revenue: ", fmt_gbp(paises_top$Revenue[i]), " | ",
            "Transacciones: ", paises_top$N[i], " | ",
            "Clientes: ", paises_top$Clientes[i], "\n\n", sep = "")
      }
    })

  })
}
