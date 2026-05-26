# =============================================================================
# MODULES/MOD_EVALUACION.R - MÓDULO TAB F5: EVALUACIÓN
# =============================================================================

mod_evaluacion_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2(icon("chart-pie"), " Evaluación del Modelo"),
    br(),
    
    fluidRow(
      shinydashboard::valueBox(
        value    = acc_pct,
        subtitle = "Accuracy",
        icon     = icon("check-circle"),
        color    = "green",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = sens_pct,
        subtitle = "Sensibilidad",
        icon     = icon("bullseye"),
        color    = "blue",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = espec_pct,
        subtitle = "Especificidad",
        icon     = icon("shield"),
        color    = "orange",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = auc_val,
        subtitle = "AUC-ROC",
        icon     = icon("star"),
        color    = "purple",
        width    = 3
      )
    ),
    
    fluidRow(
      shinydashboard::box(
        title       = "Curva ROC",
        status      = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_roc"), height = "400px")
      ),
      shinydashboard::box(
        title       = "Matriz de Confusión",
        status      = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        width       = 6,
        plotlyOutput(ns("plot_confusion"), height = "400px")
      )
    )
  )
}

mod_evaluacion_server <- function(id, roc_obj, auc_val, conf_matrix, acc_pct) {
  moduleServer(id, function(input, output, session) {
    
    output$plot_roc <- renderPlotly({
      plot_roc(roc_obj, auc_val)
    })
    
    output$plot_confusion <- renderPlotly({
      plot_confusion_matrix(conf_matrix, acc_pct)
    })
    
  })
}
