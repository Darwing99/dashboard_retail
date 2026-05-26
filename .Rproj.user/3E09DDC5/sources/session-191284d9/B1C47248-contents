# =============================================================================
# R/TABLAS.R - FUNCIONES PARA CONSTRUCCIÓN DE TABLAS INTERACTIVAS (DT)
# =============================================================================

#' Crea tabla de recomendaciones estratégicas por segmento
#'
#' @return data.frame con estrategias de marketing por segmento
build_tabla_recomendaciones <- function() {
  data.frame(
    Segmento = c(
      "Campeones",
      "Clientes Leales",
      "Clientes Recientes",
      "En Riesgo",
      "No Puede Perder",
      "Perdidos",
      "Otros"
    ),
    Estrategia = c(
      "Programa VIP: acceso anticipado, descuentos exclusivos y recompensas",
      "Upselling y cross-selling; programa de lealtad por puntos",
      "Onboarding: emails de bienvenida, guías de producto, primera oferta especial",
      "Campaña de reactivación urgente: descuentos personalizados 15-25%",
      "Encuesta de satisfacción; oferta especial de retorno; llamada proactiva",
      "Email de winback con oferta agresiva; si no responde, no invertir más",
      "Newsletter informativo; seguimiento periódico; reclasificar con más datos"
    ),
    Prioridad = c("Alta", "Alta", "Media", "Muy Alta", "Muy Alta", "Baja", "Media"),
    Canal = c(
      "Email + App",
      "Email",
      "Email",
      "Email + SMS",
      "Teléfono",
      "Email",
      "Email"
    ),
    stringsAsFactors = FALSE
  )
}

#' Formatea tabla de recomendaciones para DT
dt_recomendaciones <- function() {
  recom <- build_tabla_recomendaciones()
  
  DT::datatable(
    recom,
    options = list(
      pageLength = 10,
      dom = "t",
      columnDefs = list(
        list(
          targets = 2,  # Columna Prioridad
          render = DT::JS(
            "function(data, type, row) {
              var color = '';
              if (data === 'Muy Alta') color = '#E74C3C';
              else if (data === 'Alta') color = '#E67E22';
              else if (data === 'Media') color = '#F39C12';
              else color = '#95A5A6';
              return '<span style=\"color: white; background-color: ' + color + 
                     '; padding: 4px 8px; border-radius: 3px;\">' + data + '</span>';
            }"
          )
        )
      )
    ),
    rownames = FALSE,
    class = "stripe hover"
  )
}

#' Formatea tabla de datos raw
#'
#' @param clean data.frame limpio
#' @param n_filas número de filas a mostrar (sample)
#' @return DT::datatable renderizado
dt_datos_raw <- function(clean, n_filas = 5000) {
  set.seed(42)  # reproducibilidad
  
  df <- clean %>%
    dplyr::select(
      Invoice,
      StockCode,
      Description,
      Quantity,
      Price,
      Revenue,
      CustomerID,
      Country,
      Fecha
    ) %>%
    dplyr::slice_sample(n = min(n_filas, nrow(clean)))
  
  DT::datatable(
    df,
    options = list(
      pageLength = 15,
      scrollX = TRUE,
      searchHighlight = TRUE,
      columnDefs = list(
        list(
          targets = 0,  # Invoice
          render = DT::JS(
            "function(data, type, row) {
              return '<code>' + data + '</code>';
            }"
          )
        )
      )
    ),
    rownames = FALSE,
    filter = "top",
    class = "stripe hover"
  ) %>%
    DT::formatCurrency(columns = c("Price", "Revenue"), currency = "£")
}

#' Tabla de RFM por cliente (top clientes)
#'
#' @param rfm_data data.frame con RFM
#' @param top_n número de clientes a mostrar
#' @return DT::datatable
dt_rfm_clientes <- function(rfm_data, top_n = 100) {
  df <- rfm_data %>%
    dplyr::arrange(dplyr::desc(Monetario)) %>%
    dplyr::slice(1:top_n) %>%
    dplyr::select(
      CustomerID,
      Recencia,
      Frecuencia,
      Monetario,
      Segmento_Cliente,
      Es_Activo
    ) %>%
    dplyr::rename(
      Cliente = CustomerID,
      "Días Últim. Compra" = Recencia,
      "Nro. Compras" = Frecuencia,
      "Valor Total (£)" = Monetario,
      Segmento = Segmento_Cliente,
      Estado = Es_Activo
    )
  
  DT::datatable(
    df,
    options = list(
      pageLength = 15,
      scrollX = TRUE,
      columnDefs = list(
        list(
          targets = 4,  # Segmento
          render = DT::JS(
            "function(data, type, row) {
              var color = '';
              switch(data) {
                case 'Campeones': color = '#27AE60'; break;
                case 'Clientes Leales': color = '#3498DB'; break;
                case 'Clientes Recientes': color = '#F39C12'; break;
                case 'En Riesgo': color = '#E74C3C'; break;
                case 'No Puede Perder': color = '#E67E22'; break;
                case 'Perdidos': color = '#95A5A6'; break;
                default: color = '#34495E';
              }
              return '<span style=\"color: white; background-color: ' + color + 
                     '; padding: 4px 8px; border-radius: 3px;\">' + data + '</span>';
            }"
          )
        ),
        list(
          targets = 5,  # Estado
          render = DT::JS(
            "function(data, type, row) {
              var color = data === 'Activo' ? '#27AE60' : '#E74C3C';
              var icon = data === 'Activo' ? '✓' : '⚠';
              return '<span style=\"color: white; background-color: ' + color + 
                     '; padding: 4px 8px; border-radius: 3px;\">' + icon + ' ' + data + '</span>';
            }"
          )
        )
      )
    ),
    rownames = FALSE,
    filter = "top",
    class = "stripe hover"
  ) %>%
    DT::formatCurrency(columns = "Valor Total (£)", currency = "£")
}

#' Tabla de métricas del modelo
#'
#' @param acc_val accuracy
#' @param sens_val sensitivity
#' @param espec_val specificity
#' @param auc_val AUC
#' @return data.frame con métricas formateadas
build_tabla_metricas <- function(acc_val, sens_val, espec_val, auc_val) {
  data.frame(
    Métrica = c("Accuracy", "Sensibilidad", "Especificidad", "AUC-ROC"),
    Valor = c(
      scales::percent(acc_val, accuracy = 0.01),
      scales::percent(sens_val, accuracy = 0.01),
      scales::percent(espec_val, accuracy = 0.01),
      round(auc_val, 4)
    ),
    Interpretación = c(
      "Proporción de predicciones correctas",
      "% de clientes Activos identificados correctamente",
      "% de clientes En_Riesgo identificados correctamente",
      "Capacidad discriminativa del modelo (0.5=aleatorio, 1=perfecto)"
    ),
    stringsAsFactors = FALSE
  )
}

#' Tabla de errores OOB por número de árboles
#'
#' @param modelo_rf modelo Random Forest entrenado
#' @return data.frame con evolución del error
build_tabla_oob_error <- function(modelo_rf) {
  err_rates <- modelo_rf$err.rate %>%
    as.data.frame() %>%
    tibble::rownames_to_column("NroArboles") %>%
    dplyr::mutate(NroArboles = as.numeric(NroArboles)) %>%
    dplyr::select(NroArboles, OOB, En_Riesgo, Activo) %>%
    dplyr::rename(
      "Nro. Árboles" = NroArboles,
      "Error OOB" = OOB,
      "Error En_Riesgo" = En_Riesgo,
      "Error Activo" = Activo
    )
  
  return(err_rates)
}

#' Tabla de matriz de confusión
#'
#' @param conf_matrix resultado de caret::confusionMatrix
#' @return data.frame formateado
build_tabla_confusion <- function(conf_matrix) {
  cm <- as.data.frame(conf_matrix$table)
  cm_wide <- tidyr::pivot_wider(
    cm,
    names_from = Prediction,
    values_from = Freq
  )
  colnames(cm_wide)[1] <- "Clase Real"
  return(cm_wide)
}