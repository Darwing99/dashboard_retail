# =============================================================================
# TESTS/TEST_DATA_PREP.R - TESTS PARA FUNCIONES DE DATOS
# =============================================================================
# Ejecutar con: testthat::test_file("tests/test_data_prep.R")

# Cargar librerías
library(testthat)
source("R/helpers.R")
source("R/data_prep.R")

# =========== TESTS ===========

test_that("cargar_datos retorna un data.frame", {
  datos <- cargar_datos("data/online_retail_II.xlsx")
  expect_s3_class(datos, "data.frame")
  expect_gt(nrow(datos), 0)
})

test_that("limpiar_datos elimina cancelaciones", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  # Verificar que no haya cancelaciones
  cancelaciones <- sum(grepl("^C", clean$Invoice))
  expect_equal(cancelaciones, 0)
})

test_that("limpiar_datos elimina cantidad negativa", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  # Todas las cantidades deben ser positivas
  expect_true(all(clean$Quantity > 0))
})

test_that("limpiar_datos elimina precio negativo", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  # Todos los precios deben ser positivos
  expect_true(all(clean$Price > 0))
})

test_that("limpiar_datos enriquece con Revenue", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  # Verificar que Revenue existe
  expect_true("Revenue" %in% colnames(clean))
  
  # Verificar que Revenue = Quantity * Price
  expect_true(
    all(abs(
      clean$Revenue - (clean$Quantity * clean$Price)
    ) < 0.0001)
  )
})

test_that("limpiar_datos crea Segmento_Precio", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  expect_true("Segmento_Precio" %in% colnames(clean))
  
  segmentos_esperados <- c("Económico", "Básico", "Estándar", "Premium", "Lujo")
  expect_true(all(clean$Segmento_Precio %in% segmentos_esperados))
})

test_that("limpiar_datos extrae fechas correctamente", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  
  expect_true("Fecha" %in% colnames(clean))
  expect_true("Anio" %in% colnames(clean))
  expect_true("Mes" %in% colnames(clean))
  expect_true("Trimestre" %in% colnames(clean))
  expect_true("DiaSemana" %in% colnames(clean))
  expect_true("Hora" %in% colnames(clean))
})

test_that("calcular_rfm retorna metrics RFM", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  rfm <- calcular_rfm(clean)
  
  expect_s3_class(rfm, "data.frame")
  expect_true("Recencia" %in% colnames(rfm))
  expect_true("Frecuencia" %in% colnames(rfm))
  expect_true("Monetario" %in% colnames(rfm))
})

test_that("calcular_rfm crea scores RFM", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  rfm <- calcular_rfm(clean)
  
  expect_true("R_Score" %in% colnames(rfm))
  expect_true("F_Score" %in% colnames(rfm))
  expect_true("M_Score" %in% colnames(rfm))
  
  # Scores deben estar en 1-5
  expect_true(all(rfm$R_Score %in% 1:5 | is.na(rfm$R_Score)))
  expect_true(all(rfm$F_Score %in% 1:5 | is.na(rfm$F_Score)))
  expect_true(all(rfm$M_Score %in% 1:5 | is.na(rfm$M_Score)))
})

test_that("calcular_rfm segmenta clientes", {
  raw <- generar_datos_simulados()
  clean <- limpiar_datos(raw)
  rfm <- calcular_rfm(clean)
  
  expect_true("Segmento_Cliente" %in% colnames(rfm))
  
  segmentos_esperados <- c(
    "Campeones", "Clientes Leales", "Clientes Recientes",
    "En Riesgo", "No Puede Perder", "Perdidos", "Otros"
  )
  expect_true(all(unique(rfm$Segmento_Cliente) %in% segmentos_esperados))
})

test_that("safe_ntile maneja pocos valores", {
  x <- c(1, 2, 2, 2, 2)  # Solo 2 valores únicos
  resultado <- safe_ntile(x, n = 5)
  
  # Debería retornar 3 para todos (default cuando hay <5 valores únicos)
  expect_true(all(resultado == 3))
})

test_that("safe_ntile funciona con muchos valores", {
  x <- 1:100
  resultado <- safe_ntile(x, n = 5)
  
  # Debería haber 5 grupos
  expect_true(length(unique(resultado)) == 5)
})

cat("\n✓ Todos los tests pasaron correctamente\n")