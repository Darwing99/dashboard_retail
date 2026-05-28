# =============================================================================
# GLOBAL.R - CONFIGURACIÓN GLOBAL DE LA APLICACIÓN
# =============================================================================
# Carga librerías, funciones y realiza precomputación de datos una sola vez
# al inicio de la aplicación

# =========== LIBRERÍAS =========== 
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(tidyverse)
library(tibble)
library(lubridate)
library(scales)
library(caret)
library(randomForest)
library(pROC)
library(corrplot)
library(readxl)
library(summarytools)
library(stringr)
library(ggplot2)

# =========== CARGAR FUNCIONES PERSONALIZADAS ===========
# Helpers: colores, funciones de formato, utilidades
source("R/helpers.R", local = FALSE)

# Preparación y limpieza de datos
source("R/data_prep.R", local = FALSE)

# Entrenamiento de modelos
source("R/modelo.R", local = FALSE)

# Funciones de visualización
source("R/plots.R", local = FALSE)

# Construcción de tablas
source("R/tablas.R", local = FALSE)

# Componentes UI personalizados
source("R/ui_components.R", local = FALSE)

# Módulos Shiny (uno por pestaña)
source("modules/mod_inicio.R",     local = FALSE)
source("modules/mod_negocio.R",    local = FALSE)
source("modules/mod_eda.R",        local = FALSE)
source("modules/mod_wrangling.R",  local = FALSE)
source("modules/mod_modelo.R",     local = FALSE)
source("modules/mod_evaluacion.R", local = FALSE)
source("modules/mod_rfm.R",        local = FALSE)
source("modules/mod_datos.R",      local = FALSE)

# =========== PRECOMPUTACIÓN DE DATOS ===========
# Se ejecuta UNA SOLA VEZ al inicio de la aplicación
# En producción (Shiny Server/shinyapps.io) se comparte entre sesiones
# Para aislar por sesión, mover dentro de server()

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  DASHBOARD RETAIL - Inicializando aplicación              ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n")

# --- Cargar y preparar datos ---
cat("Cargando datos...\n")
retail_raw <- cargar_datos(archivo = "data/online_retail_II.csv")

cat("Limpiando datos...\n")
retail_clean <- limpiar_datos(retail_raw)

cat("Calculando RFM...\n")
rfm_data <- calcular_rfm(retail_clean)

# --- Entrenar modelo Random Forest ---
cat("Entrenando modelo Random Forest...\n")
modelo_resultado <- entrenar_rf(rfm_data)

# Extraer componentes del modelo
modelo_rf <- modelo_resultado$modelo
train_data <- modelo_resultado$train_data
test_data <- modelo_resultado$test_data
conf_matrix <- modelo_resultado$conf_matrix
roc_obj <- modelo_resultado$roc_obj
auc_val <- modelo_resultado$auc
acc_val <- modelo_resultado$accuracy
sens_val <- modelo_resultado$sensitivity
espec_val <- modelo_resultado$specificity

# Formatos para display
acc_pct <- scales::percent(acc_val, accuracy = 0.1)
sens_pct <- scales::percent(sens_val, accuracy = 0.1)
espec_pct <- scales::percent(espec_val, accuracy = 0.1)

cat("✓ Modelo entrenado | AUC: ", auc_val, " | Accuracy: ", acc_pct, "\n", sep = "")

# --- Estadísticas básicas para dashboard ---
total_clientes <- n_distinct(retail_raw$CustomerID)
total_transacciones <- nrow(retail_raw)
total_revenue <- sum(retail_clean$Revenue, na.rm = TRUE)
cancelaciones <- sum(stringr::str_detect(retail_raw$Invoice, "^C"))
pct_cancelaciones <- round(cancelaciones / nrow(retail_raw) * 100, 2)

cat("✓ Total clientes: ", total_clientes, "\n", sep = "")
cat("✓ Total transacciones: ", total_transacciones, "\n", sep = "")
cat("✓ Revenue total: £", round(total_revenue, 0), "\n", sep = "")
cat("✓ Cancelaciones: ", pct_cancelaciones, "%\n", sep = "")

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  Aplicación lista para usar                             ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n")