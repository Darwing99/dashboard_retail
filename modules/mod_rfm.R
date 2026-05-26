# =============================================================================
# MODULES/MOD_RFM.R - MÓDULO TAB F6: RFM
# =============================================================================

mod_rfm_ui <- function(id) {
  ns <- NS(id)

  tagList(
    h2(icon("users"), " Análisis RFM y Segmentación"),
    br(),

    # --- Visión general de segmentos ---
    fluidRow(
      shinydashboard::box(
        title       = "Distribución de Segmentos de Clientes",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_segmentos_pie"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Revenue por Segmento",
        status      = "success",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_segmentos_bar"), height = "400px")
      )
    ),

    # --- Estado de clientes por segmento ---
    fluidRow(
      shinydashboard::box(
        title       = "Clientes Activos vs En Riesgo por Segmento",
        status      = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        p("Proporción de clientes activos (compraron en los últimos 90 días) dentro de cada segmento."),
        plotlyOutput(ns("plot_activos_por_segmento"), height = "400px")
      )
    ),

    # --- Análisis RFM detallado ---
    fluidRow(
      shinydashboard::box(
        title       = "Frecuencia vs Monetario",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_rfm_scatter"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Recencia por Segmento",
        status      = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_rfm_boxplot"), height = "400px")
      )
    ),

    # --- Heatmap de scores RFM ---
    fluidRow(
      shinydashboard::box(
        title       = "Mapa de Calor R × F Score (color = M Score promedio)",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 12,
        p("Cada celda muestra el M Score promedio de los clientes con ese par de scores R y F.
           Celdas verdes indican mayor valor monetario."),
        plotlyOutput(ns("plot_rfm_scores_heatmap"), height = "450px")
      )
    ),

    # --- Tabla de recomendaciones ---
    fluidRow(
      shinydashboard::box(
        title       = "Estrategias por Segmento",
        status      = "primary",
        solidHeader = TRUE,
        width       = 12,
        DT::dataTableOutput(ns("tabla_recomendaciones"))
      )
    )
  )
}

mod_rfm_server <- function(id, rfm_data) {
  moduleServer(id, function(input, output, session) {

    output$plot_segmentos_pie <- renderPlotly({
      plot_segmentos_pie(rfm_data)
    })

    output$plot_segmentos_bar <- renderPlotly({
      plot_segmentos_revenue(rfm_data)
    })

    output$plot_activos_por_segmento <- renderPlotly({
      plot_activos_por_segmento(rfm_data)
    })

    output$plot_rfm_scatter <- renderPlotly({
      plot_rfm_scatter(rfm_data)
    })

    output$plot_rfm_boxplot <- renderPlotly({
      plot_rfm_boxplot(rfm_data)
    })

    output$plot_rfm_scores_heatmap <- renderPlotly({
      plot_rfm_scores_heatmap(rfm_data)
    })

    output$tabla_recomendaciones <- DT::renderDataTable({
      dt_recomendaciones()
    })

  })
}
