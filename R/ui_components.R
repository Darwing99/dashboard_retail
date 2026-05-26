# =============================================================================
# R/UI_COMPONENTS.R - COMPONENTES REUTILIZABLES DE UI SHINY
# =============================================================================
# Value boxes, info cards, y otros elementos comunes

#' Crea un value box con estilos corporativos
#'
#' @param titulo texto del título
#' @param valor valor a mostrar (generalmente numérico)
#' @param subtitulo texto adicional
#' @param icono nombre del ícono (Font Awesome)
#' @param color color de fondo (hex o nombre)
#' @param width ancho del box (1-12 en grid de Shiny)
#' @return shinydashboard::valueBox
custom_value_box <- function(titulo, valor, subtitulo = "", 
                             icono = "info", color = "blue", width = 3) {
  shinydashboard::valueBox(
    value = valor,
    subtitle = paste(titulo, "\n", subtitulo),
    icon = icon(icono),
    color = color,
    width = width
  )
}

#' Crea una fila de info boxes
#'
#' @param metricas lista con nombre = etiqueta, valor = número
#' @return lista de boxes para fluidRow
create_metric_boxes <- function(metricas) {
  boxes <- lapply(seq_along(metricas), function(i) {
    shinydashboard::valueBox(
      value = metricas[[i]],
      subtitle = names(metricas)[i],
      icon = icon("chart-bar"),
      color = "primary",
      width = floor(12 / length(metricas))
    )
  })
  return(boxes)
}

#' Crea un card con título y contenido
#'
#' @param titulo título del card
#' @param contenido contenido HTML o widget
#' @param icono ícono (opcional)
#' @param color color de cabecera
#' @return shinydashboard::box
info_card <- function(titulo, contenido, icono = "info", color = "primary") {
  shinydashboard::box(
    title = span(icon(icono), " ", titulo),
    status = color,
    solidHeader = TRUE,
    collapsible = TRUE,
    collapsed = FALSE,
    width = 12,
    contenido
  )
}

#' Crea un box con gráfico Plotly
plot_box <- function(titulo, plotly_objeto, icono = "chart-line", 
                     color = "primary", height = "400px") {
  shinydashboard::box(
    title = span(icon(icono), " ", titulo),
    status = color,
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    style = paste0("height: ", height, ";"),
    plotlyOutput(plotly_objeto, height = height)
  )
}

#' Crea un box con tabla DT
table_box <- function(titulo, dt_objeto, icono = "table", 
                      color = "primary") {
  shinydashboard::box(
    title = span(icon(icono), " ", titulo),
    status = color,
    solidHeader = TRUE,
    collapsible = TRUE,
    collapsed = FALSE,
    width = 12,
    DT::dataTableOutput(dt_objeto)
  )
}

#' Crea un box con texto/print output
text_box <- function(titulo, output_id, icono = "info", 
                     color = "primary") {
  shinydashboard::box(
    title = span(icon(icono), " ", titulo),
    status = color,
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    verbatimTextOutput(output_id)
  )
}

#' Crea una sección con título decorado
section_title <- function(titulo, icono = "chart-bar", color = COLORS$primary) {
  h2(
    style = paste0(
      "color: ", color, ";",
      "border-bottom: 3px solid ", color, ";",
      "padding-bottom: 10px;",
      "margin-top: 30px;",
      "margin-bottom: 20px;"
    ),
    icon(icono), " ", titulo
  )
}

#' Crea un alert informativo
info_alert <- function(titulo, mensaje, tipo = "info") {
  # Mapear tipos a colores Bootstrap
  color_map <- list(
    info = "#D1ECF1",
    success = "#D4EDDA",
    warning = "#FFF3CD",
    danger = "#F8D7DA"
  )
  
  div(
    style = paste0(
      "background-color: ", color_map[[tipo]], ";",
      "border: 1px solid #ddd;",
      "border-radius: 5px;",
      "padding: 15px;",
      "margin-bottom: 20px;"
    ),
    h4(titulo, style = "margin-top: 0;"),
    p(mensaje)
  )
}

#' Crea una fila con cards lado a lado
metric_row <- function(...) {
  items <- list(...)
  n_items <- length(items)
  col_width <- 12 / n_items
  
  boxes <- lapply(items, function(item) {
    column(width = col_width, item)
  })
  
  do.call(fluidRow, boxes)
}

#' Envuelve contenido en un panel con borde
panel_wrapper <- function(contenido, titulo = "", color = COLORS$primary) {
  div(
    style = paste0(
      "border-left: 5px solid ", color, ";",
      "padding: 15px;",
      "background-color: #f9f9f9;",
      "border-radius: 3px;"
    ),
    if (titulo != "") h4(titulo),
    contenido
  )
}

#' Crea un badge de estado
status_badge <- function(estado, tipo = "success") {
  colores <- list(
    success = "#27AE60",
    warning = "#E67E22",
    danger = "#E74C3C",
    info = "#3498DB"
  )
  
  span(
    estado,
    style = paste0(
      "color: white;",
      "background-color: ", colores[[tipo]], ";",
      "padding: 4px 8px;",
      "border-radius: 3px;",
      "font-weight: bold;"
    )
  )
}

#' Crea un indicador KPI grande
kpi_indicator <- function(valor, label, icono = "star", 
                          color = COLORS$primary) {
  div(
    style = paste0(
      "text-align: center;",
      "padding: 20px;",
      "background: linear-gradient(135deg, ", color, " 0%, ", 
      adjustcolor(color, alpha.f = 0.7), " 100%);",
      "border-radius: 8px;",
      "color: white;"
    ),
    icon(icono, class = "fa-3x"),
    br(),
    h2(valor, style = "margin: 10px 0;"),
    p(label, style = "margin: 0;")
  )
}

#' Crea una tabla comparativa
comparison_table <- function(items_list) {
  # items_list: list(titulo = c("Item1", "Item2", ...), 
  #                  metric1 = c(val1, val2, ...),
  #                  metric2 = c(val3, val4, ...))
  df <- as.data.frame(items_list, check.names = FALSE)
  
  DT::datatable(
    df,
    options = list(
      dom = "t",
      paging = FALSE,
      columnDefs = list(
        list(targets = 0, searchable = FALSE)
      )
    ),
    rownames = FALSE,
    class = "stripe hover"
  )
}