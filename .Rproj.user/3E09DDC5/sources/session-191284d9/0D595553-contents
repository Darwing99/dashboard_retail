# =============================================================================
# R/MODELO.R - FUNCIONES DE ENTRENAMIENTO DE MODELOS
# =============================================================================

#' Entrena un modelo Random Forest para predecir clientes activos
#'
#' Divide datos en train/test (75/25), entrena RF y evalúa con métricas
#' de confusión y curva ROC
#'
#' @param rfm_data data.frame con métricas RFM (output de calcular_rfm)
#' @return lista con modelo, datos de train/test y métricas
#'
#' @details
#' Variables predictoras: Recencia, Frecuencia, Monetario, R_Score, F_Score, M_Score
#' Variable objetivo: Es_Activo (Activo vs En_Riesgo)
#'
#' Parámetros RF:
#' - ntree = 200: número de árboles
#' - mtry = 3: variables por árbol
#' - importance = TRUE: calcular importancia
entrenar_rf <- function(rfm_data) {
  # Preparar datos para ML
  datos_ml <- rfm_data %>%
    dplyr::select(
      Recencia, Frecuencia, Monetario,
      R_Score, F_Score, M_Score,
      Es_Activo
    ) %>%
    na.omit()
  
  # Dividir en train/test (75/25)
  set.seed(123)
  idx_train <- caret::createDataPartition(
    datos_ml$Es_Activo,
    p = 0.75,
    list = FALSE
  )
  
  train_data <- datos_ml[idx_train, ]
  test_data <- datos_ml[-idx_train, ]
  
  # Entrenar modelo Random Forest
  modelo_rf <- randomForest::randomForest(
    Es_Activo ~ .,
    data = train_data,
    ntree = 200,
    mtry = 3,
    importance = TRUE,
    seed = 123
  )
  
  # Hacer predicciones
  pred_clase <- predict(modelo_rf, test_data)
  pred_prob <- predict(modelo_rf, test_data, type = "prob")
  
  # Calcular matriz de confusión
  conf_matrix <- caret::confusionMatrix(
    pred_clase,
    test_data$Es_Activo,
    positive = "Activo"
  )
  
  # Calcular curva ROC y AUC
  roc_obj <- pROC::roc(
    as.numeric(test_data$Es_Activo == "Activo"),
    pred_prob[, "Activo"],
    quiet = TRUE
  )
  
  # Extraer métricas
  auc <- round(pROC::auc(roc_obj), 4)
  accuracy <- round(as.numeric(conf_matrix$overall["Accuracy"]), 4)
  sensitivity <- round(as.numeric(conf_matrix$byClass["Sensitivity"]), 4)
  specificity <- round(as.numeric(conf_matrix$byClass["Specificity"]), 4)
  
  # Retornar lista con todos los componentes
  list(
    modelo = modelo_rf,
    train_data = train_data,
    test_data = test_data,
    pred_clase = pred_clase,
    pred_prob = pred_prob,
    conf_matrix = conf_matrix,
    roc_obj = roc_obj,
    auc = auc,
    accuracy = accuracy,
    sensitivity = sensitivity,
    specificity = specificity
  )
}

#' Obtiene importancia de variables del modelo RF
#'
#' @param modelo modelo Random Forest entrenado
#' @return data.frame ordenado por importancia
get_importancia <- function(modelo) {
  randomForest::importance(modelo) %>%
    as.data.frame() %>%
    tibble::rownames_to_column("Variable") %>%
    dplyr::arrange(dplyr::desc(MeanDecreaseGini))
}

#' Genera predicciones para un nuevo cliente
#'
#' @param modelo modelo entrenado
#' @param nuevoCliente data.frame con 1 fila y cols: Recencia, Frecuencia, etc
#' @return lista con predicción de clase y probabilidad
predecir_cliente <- function(modelo, nuevoCliente) {
  pred_clase <- predict(modelo, nuevoCliente)
  pred_prob <- predict(modelo, nuevoCliente, type = "prob")
  
  list(
    clase = pred_clase,
    prob_activo = round(pred_prob[1, "Activo"] * 100, 2),
    prob_riesgo = round(pred_prob[1, "En_Riesgo"] * 100, 2)
  )
}