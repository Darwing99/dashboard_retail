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
    ),

    # --- Visualizaciones con ggplot2 ---
    h3(icon("chart-area"), " Visualizaciones con ggplot2"),
    fluidRow(
      shinydashboard::box(
        title       = "Histograma de Revenue por Transacción (ggplot2)",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        p("Distribución de ingresos por transacción (hasta el percentil 95)."),
        plotOutput(ns("gg_histograma"), height = "380px")
      ),
      shinydashboard::box(
        title       = "Boxplot de Revenue por Segmento de Precio (ggplot2)",
        status      = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        p("Variabilidad del revenue según el segmento de precio del producto."),
        plotOutput(ns("gg_boxplot"), height = "380px")
      )
    ),

    # --- Resumen estadístico con summarytools ---
    h3(icon("table"), " Resumen Detallado de Variables (summarytools)"),
    fluidRow(
      shinydashboard::box(
        title       = "dfSummary — Variables Numéricas y Categóricas Clave",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        p("Estadísticas descriptivas completas generadas con summarytools::dfSummary()."),
        verbatimTextOutput(ns("eda_summarytools"))
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

    # --- ggplot2: Histograma de Revenue ---
    output$gg_histograma <- renderPlot({
      p95 <- quantile(retail_clean$Revenue, 0.95, na.rm = TRUE)
      retail_clean %>%
        dplyr::filter(Revenue <= p95) %>%
        ggplot2::ggplot(ggplot2::aes(x = Revenue)) +
        ggplot2::geom_histogram(bins = 40, fill = "#1A5276", color = "white", alpha = 0.85) +
        ggplot2::labs(
          title    = "Distribución de Revenue por Transacción",
          subtitle = "Registros filtrados hasta el percentil 95",
          x        = "Revenue (£)",
          y        = "Número de Transacciones"
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::scale_x_continuous(labels = scales::dollar_format(prefix = "£"))
    })

    # --- ggplot2: Boxplot por Segmento de Precio ---
    output$gg_boxplot <- renderPlot({
      p95 <- quantile(retail_clean$Revenue, 0.95, na.rm = TRUE)
      orden <- retail_clean %>%
        dplyr::group_by(Segmento_Precio) %>%
        dplyr::summarise(med = median(Revenue, na.rm = TRUE), .groups = "drop") %>%
        dplyr::arrange(med) %>%
        dplyr::pull(Segmento_Precio)

      retail_clean %>%
        dplyr::filter(Revenue <= p95) %>%
        dplyr::mutate(Segmento_Precio = factor(Segmento_Precio, levels = orden)) %>%
        ggplot2::ggplot(ggplot2::aes(x = Segmento_Precio, y = Revenue, fill = Segmento_Precio)) +
        ggplot2::geom_boxplot(alpha = 0.75, outlier.alpha = 0.3, outlier.size = 1) +
        ggplot2::labs(
          title = "Revenue por Segmento de Precio",
          x     = "Segmento de Precio",
          y     = "Revenue (£)"
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(legend.position = "none") +
        ggplot2::scale_y_continuous(labels = scales::dollar_format(prefix = "£"))
    })

    # --- summarytools: dfSummary ---
    output$eda_summarytools <- renderPrint({
      vars_df <- retail_clean %>%
        dplyr::select(Revenue, Quantity, Price, Segmento_Precio) %>%
        as.data.frame()
      summarytools::dfSummary(
        vars_df,
        plain.ascii = TRUE,
        style       = "grid",
        graph.col   = FALSE,
        valid.col   = TRUE
      )
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
