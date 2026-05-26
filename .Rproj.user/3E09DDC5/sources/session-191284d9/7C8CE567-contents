# =============================================================================
# R/HELPERS.R - UTILIDADES Y CONSTANTES CENTRALIZADAS
# =============================================================================
# Colores corporativos, funciones de formato y funciones de seguridad

# =========== PALETA DE COLORES CORPORATIVA ===========
# Centraliza todos los colores: cambiar aquí se refleja en toda la app
COLORS <- list(
  primary   = "#1A5276",    # Azul oscuro principal
  success   = "#2ECC71",    # Verde éxito
  danger    = "#E74C3C",    # Rojo alerta
  warning   = "#E67E22",    # Naranja advertencia
  purple    = "#8E44AD",    # Morado
  dark      = "#2C3E50",    # Gris muy oscuro
  info      = "#2980B9",    # Azul info
  light_red = "#FADBD8",    # Rojo claro para heatmaps
  light_gray = "#ECF0F1",   # Gris claro para fondos
  success_light = "#D5F4E6" # Verde claro
)

# =========== FUNCIÓN: NTILE SEGURO ===========
#' ntile protegido para segmentación RFM
#'
#' Si hay muy pocos valores únicos, asigna score 3 por defecto
#' en lugar de fallar con un error
#'
#' @param x vector numérico a segmentar
#' @param n número de segmentos (default 5)
#' @return vector de scores 1:n
safe_ntile <- function(x, n = 5) {
  if (length(unique(na.omit(x))) < n) {
    return(rep(3L, length(x)))
  }
  dplyr::ntile(x, n)
}

# =========== FUNCIÓN: FORMATOS MONETARIOS ===========
#' Formatea números como £ con separadores de miles
#'
#' @param x valor numérico
#' @param decimales número de decimales (default 0)
#' @return string formateado: "£1,234.56"
fmt_gbp <- function(x, decimales = 0) {
  paste0("£", scales::comma(round(x, decimales)))
}

#' Formatea números con separadores de miles
fmt_number <- function(x, decimales = 0) {
  scales::comma(round(x, decimales))
}

# =========== FUNCIÓN: PALETA PARA SEGMENTOS ===========
#' Retorna color consistente para cada segmento de cliente
#' 
#' @param segmento nombre del segmento (ej: "Campeones")
#' @return código hex de color
get_color_segmento <- function(segmento) {
  colores_seg <- list(
    "Campeones"           = "#27AE60",  # Verde fuerte
    "Clientes Leales"     = "#3498DB",  # Azul
    "Clientes Recientes"  = "#F39C12",  # Naranja
    "En Riesgo"           = "#E74C3C",  # Rojo
    "No Puede Perder"     = "#E67E22",  # Naranja oscuro
    "Perdidos"            = "#95A5A6",  # Gris
    "Otros"               = "#BDC3C7"   # Gris claro
  )
  return(colores_seg[[segmento]] %||% "#34495E")
}

# =========== FUNCIÓN: CREAR ETIQUETA CON ICONO ===========
#' Crea una etiqueta HTML con icono para value_box
#'
#' @param valor valor numérico a mostrar
#' @param etiqueta texto de descripción
#' @param icono nombre del ícono (de Font Awesome)
#' @param color código hex o nombre de color
#' @return HTML renderizado
create_label_icon <- function(valor, etiqueta, icono, color = COLORS$primary) {
  list(
    h4(style = paste0("color: ", color, ";"), 
       icon(icono), " ", valor),
    p(style = "margin-top: 5px; color: #7F8C8D;", 
      etiqueta)
  )
}