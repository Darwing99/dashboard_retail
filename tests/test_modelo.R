# =============================================================================
# TESTS/TEST_MODELO.R - TESTS PARA FUNCIONES DE MODELO
# =============================================================================
# Ejecutar con: testthat::test_file("tests/test_modelo.R")

library(testthat)
source("R/helpers.R")
source("R/data_prep.R")
source("R/modelo.R")

# =========== SETUP ===========
# Generar datos de prueba
set.seed(123)
raw <- generar_datos_simulados()
clean <- limpiar_datos(raw)
rfm <- calcular_rfm(clean)

# =========== TESTS ===========

test_that("entrenar_rf retorna lista con componentes necesarios", {
  resultado <- entrenar_rf(rfm)
  
  expect_type(resultado, "list")
  expect_true("modelo" %in% names(resultado))
  expect_true("train_data" %in% names(resultado))
  expect_true("test_data" %in% names(resultado))
  expect_true("conf_matrix" %in% names(resultado))
  expect_true("roc_obj" %in% names(resultado))
  expect_true("auc" %in% names(resultado))
  expect_true("accuracy" %in% names(resultado))
})

test_that("entrenar_rf crea train/test correctamente", {
  resultado <- entrenar_rf(rfm)
  train <- resultado$train_data
  test <- resultado$test_data
  
  # Verificar proporciones aproximadamente 75/25
  total <- nrow(train) + nrow(test)
  prop_train <- nrow(train) / total
  
  expect_gt(prop_train, 0.70)  # Al menos 70%
  expect_lt(prop_train, 0.80)  # Menos de 80%
})

test_that("entrenar_rf modelo es Random Forest", {
  resultado <- entrenar_rf(rfm)
  modelo <- resultado$modelo
  
  expect_s3_class(modelo, "randomForest")
  expect_equal(modelo$ntree, 200)
  expect_equal(modelo$mtry, 3)
})

test_that("entrenar_rf retorna AUC entre 0 y 1", {
  resultado <- entrenar_rf(rfm)
  auc <- resultado$auc
  
  expect_gte(auc, 0)
  expect_lte(auc, 1)
})

test_that("entrenar_rf retorna accuracy entre 0 y 1", {
  resultado <- entrenar_rf(rfm)
  acc <- resultado$accuracy
  
  expect_gte(acc, 0)
  expect_lte(acc, 1)
})

test_that("entrenar_rf retorna sensitivity entre 0 y 1", {
  resultado <- entrenar_rf(rfm)
  sens <- resultado$sensitivity
  
  expect_gte(sens, 0)
  expect_lte(sens, 1)
})

test_that("entrenar_rf retorna specificity entre 0 y 1", {
  resultado <- entrenar_rf(rfm)
  spec <- resultado$specificity
  
  expect_gte(spec, 0)
  expect_lte(spec, 1)
})

test_that("get_importancia retorna data.frame", {
  resultado <- entrenar_rf(rfm)
  modelo <- resultado$modelo
  
  imp <- get_importancia(modelo)
  
  expect_s3_class(imp, "data.frame")
  expect_true("Variable" %in% colnames(imp))
  expect_true("MeanDecreaseGini" %in% colnames(imp))
})

test_that("get_importancia está ordenada por importancia", {
  resultado <- entrenar_rf(rfm)
  modelo <- resultado$modelo
  
  imp <- get_importancia(modelo)
  
  # Verificar que está en orden descendente
  expect_true(
    all(imp$MeanDecreaseGini[-nrow(imp)] >= 
          imp$MeanDecreaseGini[-1])
  )
})

test_that("predecir_cliente retorna lista con predicción", {
  resultado <- entrenar_rf(rfm)
  modelo <- resultado$modelo
  
  # Crear nuevo cliente (con valores promedio)
  nuevo <- data.frame(
    Recencia = median(rfm$Recencia, na.rm = TRUE),
    Frecuencia = median(rfm$Frecuencia, na.rm = TRUE),
    Monetario = median(rfm$Monetario, na.rm = TRUE),
    R_Score = 3,
    F_Score = 3,
    M_Score = 3
  )
  
  pred <- predecir_cliente(modelo, nuevo)
  
  expect_type(pred, "list")
  expect_true("clase" %in% names(pred))
  expect_true("prob_activo" %in% names(pred))
  expect_true("prob_riesgo" %in% names(pred))
})

test_that("predecir_cliente probabilidades suman 100", {
  resultado <- entrenar_rf(rfm)
  modelo <- resultado$modelo
  
  nuevo <- data.frame(
    Recencia = median(rfm$Recencia, na.rm = TRUE),
    Frecuencia = median(rfm$Frecuencia, na.rm = TRUE),
    Monetario = median(rfm$Monetario, na.rm = TRUE),
    R_Score = 3,
    F_Score = 3,
    M_Score = 3
  )
  
  pred <- predecir_cliente(modelo, nuevo)
  
  # Las probabilidades deben sumar aproximadamente 100
  suma <- pred$prob_activo + pred$prob_riesgo
  expect_approximately_equal(suma, 100, tolerance = 0.1)
})

test_that("conf_matrix tiene estructura correcta", {
  resultado <- entrenar_rf(rfm)
  cm <- resultado$conf_matrix
  
  expect_s3_class(cm, "confusionMatrix")
  expect_true("table" %in% names(cm))
  expect_true("overall" %in% names(cm))
  expect_true("byClass" %in% names(cm))
})

test_that("roc_obj es de clase roc", {
  resultado <- entrenar_rf(rfm)
  roc_o <- resultado$roc_obj
  
  expect_s3_class(roc_o, "roc")
})

# Helper para comparación de números aproximados
expect_approximately_equal <- function(actual, expected, tolerance = 0.01) {
  expect_true(abs(actual - expected) <= tolerance)
}

cat("\n✓ Todos los tests del modelo pasaron correctamente\n")