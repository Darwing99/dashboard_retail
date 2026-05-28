# =============================================================================
# R/DATA_PREP.R - FUNCIONES DE CARGA Y PREPARACIÓN DE DATOS
# =============================================================================

#' Carga dataset de retail desde Excel
#'
#' Lee el archivo online_retail_II.xlsx y retorna un data.frame.
#' Si el archivo no existe, genera datos simulados.
#'
#' @param archivo ruta al archivo Excel (default "online_retail_II.xlsx")
#' @return data.frame con datos crudos
#' 
#' @details
#' Intenta leer la hoja "page" del Excel.
#' Si falla, crea un dataset simulado para demostración.
cargar_datos <- function(archivo = "online_retail_II.xlsx") {
  if (file.exists(archivo)) {
    tryCatch({
      df1 <- readxl::read_excel(archivo, sheet = "page")
      raw <- dplyr::bind_rows(df1)
      cat("Dataset cargado desde:", archivo, "\n")
      return(raw)
    }, error = function(e) {
      warning(paste(
        "No se pudo leer el Excel (", conditionMessage(e), ").",
        "Generando datos simulados..."
      ))
      return(generar_datos_simulados())
    })
  } else {
    cat("! Archivo no encontrado:", archivo, "\n")
    cat("  Generando datos simulados para demostración...\n")
    return(generar_datos_simulados())
  }
}

#' Genera dataset simulado para demostración
#'
#' Crea un conjunto de datos sintético con estructura similar
#' a online_retail_II.xlsx para cuando no se encuentra el archivo real
#'
#' @return data.frame simulado
generar_datos_simulados <- function() {
  set.seed(123)
  
  fechas <- seq(as.POSIXct("2022-01-01"), 
                as.POSIXct("2023-12-31"), 
                by = "1 hour")
  
  n <- 10000
  
  data.frame(
    Invoice = paste0(
      sample(c("", "C"), n, replace = TRUE, prob = c(0.95, 0.05)),
      sample(500000:506000, n, replace = TRUE)
    ),
    StockCode = sample(paste0("SKU", 1000:2000), n, replace = TRUE),
    Description = sample(
      c("Mug", "Notebook", "T-Shirt", "Hat", "Keychain", 
        "Poster", "Sticker", "Cup", "Candle", "Bookmark"),
      n, replace = TRUE
    ),
    Quantity = rpois(n, 3) + 1,
    InvoiceDate = sample(fechas, n),
    Price = rgamma(n, shape = 2, rate = 1/5),
    CustomerID = sample(10000:50000, n, replace = TRUE),
    Country = sample(
      c("United Kingdom", "Netherlands", "EIRE", "Germany", "France",
        "Australia", "Spain", "Italy", "Poland", "Sweden"),
      n, replace = TRUE
    ),
    stringsAsFactors = FALSE
  )
}

#' Limpia y enriquece el dataset raw
#'
#' Elimina duplicados, valores inválidos y calcula nuevas variables:
#' - Parsing de fechas y extracción de componentes temporales
#' - Cálculo de Revenue (Quantity × Price)
#' - Segmentación de precio
#'
#' @param raw data.frame sin procesar
#' @return data.frame limpio y enriquecido
limpiar_datos <- function(raw) {
  raw %>%
    # Eliminar duplicados exactos
    dplyr::distinct() %>%
    # Filtrar valores inválidos
    dplyr::filter(
      !stringr::str_detect(Invoice, "^C"), # Excluir cancelaciones
      Quantity > 0,                    # Cantidad positiva
      Price > 0,                       # Precio positivo
      !is.na(CustomerID),              # CustomerID válido
      !is.na(StockCode)                # StockCode válido
    ) %>%
    dplyr::mutate(
      # Estandarizar CustomerID como string
      CustomerID = as.character(as.integer(CustomerID)),
      
      # Parsing y extracción de fechas
      InvoiceDate = as.POSIXct(InvoiceDate),
      Fecha = as.Date(InvoiceDate),
      Anio = lubridate::year(InvoiceDate),
      Mes = lubridate::month(InvoiceDate),
      Trimestre = lubridate::quarter(InvoiceDate),
      DiaSemana = lubridate::wday(InvoiceDate, label = TRUE, abbr = FALSE),
      Hora = lubridate::hour(InvoiceDate),
      
      # Cálculo de métricas
      Revenue = Quantity * Price,
      
      # Segmentación de precio
      Segmento_Precio = dplyr::case_when(
        Price < 1  ~ "Económico",
        Price < 5  ~ "Básico",
        Price < 15 ~ "Estándar",
        Price < 50 ~ "Premium",
        TRUE       ~ "Lujo"
      ),
      
      .keep = "all"
    )
}

#' Calcula métricas RFM y segmentos de cliente
#'
#' RFM = Recencia, Frecuencia, Monetario
#' Define segmentos según combinaciones de R, F, M scores
#'
#' @param clean data.frame limpio (output de limpiar_datos)
#' @return data.frame con métricas RFM y segmentación
#'
#' @details
#' Usa safe_ntile() para evitar errores si hay muy pocos clientes.
#' Define 7 segmentos de cliente basados en comportamiento RFM.
calcular_rfm <- function(clean) {
  # Fecha de referencia: día después del más reciente
  fecha_ref <- max(clean$Fecha, na.rm = TRUE) + 1
  
  # Calcular métricas por cliente
  rfm <- clean %>%
    dplyr::group_by(CustomerID) %>%
    dplyr::summarise(
      Recencia = as.numeric(fecha_ref - max(Fecha, na.rm = TRUE)),
      Frecuencia = dplyr::n_distinct(Invoice),
      Monetario = sum(Revenue, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Asignar scores RFM
  rfm %>%
    dplyr::mutate(
      # Scores 1-5: Recencia inversa (menor es mejor)
      R_Score = safe_ntile(dplyr::desc(Recencia), n = 5),
      # Scores 1-5: Mayor frecuencia es mejor
      F_Score = safe_ntile(Frecuencia, n = 5),
      # Scores 1-5: Mayor valor monetario es mejor
      M_Score = safe_ntile(Monetario, n = 5),
      
      # Definir segmentos según combinación de scores
      Segmento_Cliente = dplyr::case_when(
        R_Score >= 4 & F_Score >= 4 & M_Score >= 4  ~ "Campeones",
        R_Score >= 3 & F_Score >= 3                  ~ "Clientes Leales",
        R_Score >= 4 & F_Score <= 2                  ~ "Clientes Recientes",
        R_Score <= 2 & F_Score >= 3                  ~ "En Riesgo",
        R_Score <= 2 & F_Score <= 2 & M_Score >= 3   ~ "No Puede Perder",
        R_Score <= 1                                 ~ "Perdidos",
        TRUE                                         ~ "Otros"
      ),
      
      # Variable objetivo para modelo: activo si compró en últimos 90 días
      Es_Activo = factor(
        ifelse(Recencia <= 90, "Activo", "En_Riesgo"),
        levels = c("En_Riesgo", "Activo")
      )
    )
}