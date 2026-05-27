# =============================================================================
# MODULES/MOD_INICIO.R - MÓDULO TAB INICIO
# =============================================================================

mod_inicio_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h1(
      "Dashboard Retail - Análisis de Ventas y Comportamiento",
      style = paste0("color: ", COLORS$primary, "; margin-bottom: 30px;")
    ),
    
    # Fila de KPIs
    fluidRow(
      shinydashboard::valueBox(
        value    = formatC(total_clientes, format = "f", digits = 0, big.mark = ","),
        subtitle = "Total Clientes",
        icon     = icon("users"),
        color    = "blue",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = formatC(total_transacciones, format = "f", digits = 0, big.mark = ","),
        subtitle = "Transacciones",
        icon     = icon("shopping-cart"),
        color    = "green",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = fmt_gbp(total_revenue),
        subtitle = "Revenue Total",
        icon     = icon("pound-sign"),
        color    = "purple",
        width    = 3
      ),
      shinydashboard::valueBox(
        value    = paste0(pct_cancelaciones, "%"),
        subtitle = "Cancelaciones",
        icon     = icon("exclamation-triangle"),
        color    = "red",
        width    = 3
      )
    ),
    
    br(),
    
    fluidRow(
      column(
        width = 12,
        shinydashboard::box(
          title       = "Bienvenida",
          status      = "primary",
          solidHeader = TRUE,
          width       = 12,
          p("Este dashboard interactivo realiza un análisis integral del comportamiento de compra de clientes en retail."),
          p("Autores"),
          tags$ul(
            tags$li("Gissela Jocelyne Grandez Berrios"),
            tags$li("Darwing Hernandez Castellanos"),
            tags$li("Daniel Alexander Cuellar")
          ),
          p("Usa navegación a través de las pestañas para explorar:"),
          tags$ul(
            tags$li("F1 Negocio: métricas y KPIs principales"),
            tags$li("F2 EDA: análisis exploratorio de datos"),
            tags$li("F3 Wrangling: datos limpios y enriquecidos"),
            tags$li("F4 Modelado: Random Forest para predecir clientes activos"),
            tags$li("F5 Evaluación: métricas y desempeño del modelo"),
            tags$li("F6 RFM: segmentación y análisis de cliente"),
            tags$li("F7 Datos: consulta de registros raw")
          )
        )
      )
    )
  )
}

mod_inicio_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Sin outputs reactivos — todo es estático (calculado en global.R)
  })
}
