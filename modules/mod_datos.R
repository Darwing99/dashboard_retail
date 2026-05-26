# =============================================================================
# MODULES/MOD_DATOS.R - MÓDULO TAB F7: DATOS RAW
# =============================================================================

mod_datos_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2(icon("database"), " Datos Raw (Muestra)"),
    br(),
    p("Tabla interactiva con 5,000 registros aleatorios. Use el filtro superior para buscar."),
    br(),
    
    fluidRow(
      shinydashboard::box(
        title       = "Registros de Transacciones",
        status      = "primary",
        solidHeader = TRUE,
        width       = 12,
        DT::dataTableOutput(ns("tabla_datos"))
      )
    )
  )
}

mod_datos_server <- function(id, retail_clean) {
  moduleServer(id, function(input, output, session) {
    
    output$tabla_datos <- DT::renderDataTable({
      dt_datos_raw(retail_clean, n_filas = 5000)
    })
    
  })
}
