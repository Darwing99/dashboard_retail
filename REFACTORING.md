# Refactorización: Arquitectura con Shiny Modules

**Fecha:** 18 de mayo de 2026  
**Autor:** Darwing Hernández

---

## Resumen

Se refactorizó el dashboard de arquitectura monolítica (`ui.R` / `server.R` únicos)
a una arquitectura basada en **Shiny Modules**, donde cada pestaña del dashboard es
un módulo independiente con su propia UI y lógica de servidor.

---

## Problema previo

Además de la refactorización, se corrigió un bug existente:

- El archivo `R/ modelo.R` tenía un **espacio en el nombre** (`R/ modelo.R`)
  pero `global.R` lo llamaba como `R/modelo.R`. Esto causaba el error:

  ```
  Warning: cannot open file 'R/modelo.R': No such file or directory
  Error in file(filename, "r", encoding = encoding): cannot open the connection
  ```

  **Solución:** Se renombró el archivo eliminando el espacio.

---

## Cambios realizados

### 1. Módulos creados en `modules/`

Se llenaron los 7 archivos placeholder existentes y se creó uno nuevo:

| Archivo | Pestaña | Descripción |
|---|---|---|
| `modules/mod_inicio.R` | 📊 Inicio | KPIs globales y mensaje de bienvenida |
| `modules/mod_negocio.R` | 🏢 F1: Negocio | Ventas en el tiempo y top países |
| `modules/mod_eda.R` | 📈 F2: EDA | Resumen estadístico y distribuciones |
| `modules/mod_wrangling.R` | 🔧 F3: Wrangling | Info de cancelaciones y limpieza |
| `modules/mod_modelo.R` | 🧠 F4: Modelado | Resumen y gráficos del Random Forest |
| `modules/mod_evaluacion.R` | 📋 F5: Evaluación | Curva ROC y matriz de confusión |
| `modules/mod_rfm.R` | 🎯 F6: RFM | Segmentación y estrategias RFM |
| `modules/mod_datos.R` *(nuevo)* | 📑 F7: Datos Raw | Tabla interactiva de transacciones |

Cada módulo expone dos funciones siguiendo la convención estándar de Shiny:

```r
mod_X_ui(id)            # Define la interfaz del módulo
mod_X_server(id, ...)   # Define la lógica reactiva del módulo
```

Los IDs internos de outputs usan `ns()` para evitar colisiones entre módulos:

```r
mod_negocio_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("plot_ventas_mes"))  # ID real: "negocio-plot_ventas_mes"
}
```

---

### 2. `global.R` — Agregado carga de módulos

Se añadieron 8 líneas `source()` al final del bloque de funciones personalizadas,
**antes** de la precomputación de datos:

```r
# Módulos Shiny (uno por pestaña)
source("modules/mod_inicio.R",     local = FALSE)
source("modules/mod_negocio.R",    local = FALSE)
source("modules/mod_eda.R",        local = FALSE)
source("modules/mod_wrangling.R",  local = FALSE)
source("modules/mod_modelo.R",     local = FALSE)
source("modules/mod_evaluacion.R", local = FALSE)
source("modules/mod_rfm.R",        local = FALSE)
source("modules/mod_datos.R",      local = FALSE)
```

---

### 3. `ui.R` — Simplificado con llamadas a módulos

Cada `tabItem` que antes contenía toda su HTML fue reemplazado por una sola
llamada al módulo correspondiente.

**Antes (~430 líneas):**
```r
shinydashboard::tabItem(
  tabName = "negocio",
  h2(icon("briefcase"), " Análisis de Negocio"),
  br(),
  fluidRow(
    shinydashboard::box(
      title = "Ventas a lo largo del tiempo",
      ...
      plotlyOutput("plot_ventas_mes", height = "400px")
    )
  ),
  # ...~30 líneas más
)
```

**Después (~52 líneas):**
```r
shinydashboard::tabItem(tabName = "negocio", mod_negocio_ui("negocio"))
```

---

### 4. `server.R` — Simplificado con llamadas a módulos

Cada bloque de `output$...` fue reemplazado por una sola llamada al server del módulo,
pasando los datos necesarios como argumentos explícitos.

**Antes (~218 líneas):**
```r
output$plot_ventas_mes <- renderPlotly({ plot_ventas_mes(retail_clean) })
output$plot_top_paises <- renderPlotly({ plot_top_paises(retail_clean, top_n = 10) })
output$info_general    <- renderPrint({ ... })
```

**Después (~40 líneas):**
```r
mod_negocio_server("negocio", retail_clean = retail_clean)
```

---

### 5. `app.R` — Reforzado orden de carga

Se agregaron los `source()` de módulos directamente en `app.R` (entre `global.R`
y `ui.R`) para proteger contra problemas de hot-reload de Shiny, donde el
file-watcher puede re-evaluar `ui.R` antes de que `global.R` termine:

```r
source("global.R", local = FALSE)

# Módulos explícitos (garantiza disponibilidad antes de evaluar ui.R)
source("modules/mod_inicio.R",     local = FALSE)
# ...

source("ui.R", local = FALSE)
source("server.R", local = FALSE)
shinyApp(ui = ui, server = server)
```

---

## Comparativa de tamaño

| Archivo | Antes | Después |
|---|---|---|
| `ui.R` | 430 líneas | 52 líneas |
| `server.R` | 218 líneas | 40 líneas |
| `app.R` | 14 líneas | 25 líneas |
| `global.R` | 100 líneas | 110 líneas |
| `modules/*.R` | 0 bytes (vacíos) | 8 archivos con código |

---

## Estructura final del proyecto

```
dashboard_retail/
├── app.R                  # Punto de entrada
├── global.R               # Librerías, funciones y datos
├── ui.R                   # UI principal (sin contenido inline)
├── server.R               # Server principal (sin outputs inline)
│
├── modules/
│   ├── mod_inicio.R
│   ├── mod_negocio.R
│   ├── mod_eda.R
│   ├── mod_wrangling.R
│   ├── mod_modelo.R
│   ├── mod_evaluacion.R
│   ├── mod_rfm.R
│   └── mod_datos.R        # ← nuevo
│
├── R/
│   ├── helpers.R
│   ├── data_prep.R
│   ├── modelo.R           # ← renombrado (eliminado espacio)
│   ├── plots.R
│   ├── tablas.R
│   └── ui_components.R
│
├── data/
├── tests/
└── www/
```

---

## Beneficios de la nueva arquitectura

- **Mantenibilidad:** cada pestaña es independiente; modificar una no afecta las otras.
- **Legibilidad:** `ui.R` y `server.R` son ahora archivos de orquestación, no de implementación.
- **Escalabilidad:** agregar una nueva pestaña = crear un nuevo `mod_X.R` y dos líneas en `ui.R` / `server.R`.
- **Aislamiento de IDs:** `ns()` previene colisiones entre los IDs de outputs de distintos módulos.
- **Testabilidad:** cada módulo puede probarse de forma aislada.

---

## Actualización: Integración de librerías CRISP-DM (27 de mayo de 2026)

**Autor:** Darwing Hernández

Se integraron las librerías faltantes para cumplir con los requisitos de la metodología CRISP-DM exigidos por el enunciado del proyecto.

### Cambios en `global.R`

Agregadas 3 librerías explícitas al bloque de carga:

```r
library(summarytools)  # Resumen estadístico descriptivo (Fase 2 EDA)
library(stringr)       # Manipulación de texto (Fase 3 Wrangling)
library(ggplot2)       # Gráficos estáticos (Fase 2 EDA)
```

> Nota: `stringr` y `ggplot2` forman parte del ecosistema `tidyverse`, pero se declaran explícitamente para documentar su uso conforme al enunciado.

### Cambios en `R/data_prep.R` y `global.R`

Reemplazado `grepl()` (base R) por `stringr::str_detect()` en todos los puntos donde se detectan cancelaciones:

```r
# Antes (base R):
!grepl("^C", Invoice)
sum(grepl("^C", retail_raw$Invoice))

# Después (stringr):
!stringr::str_detect(Invoice, "^C")
sum(stringr::str_detect(retail_raw$Invoice, "^C"))
```

### Cambios en `modules/mod_eda.R`

Agregados 3 bloques nuevos al final del tab F2 - EDA:

| Elemento nuevo | Función R | Output Shiny |
|---|---|---|
| Histograma de Revenue | `ggplot2::geom_histogram()` | `plotOutput("gg_histograma")` |
| Boxplot por Segmento de Precio | `ggplot2::geom_boxplot()` | `plotOutput("gg_boxplot")` |
| Resumen estadístico detallado | `summarytools::dfSummary()` | `verbatimTextOutput("eda_summarytools")` |

### Cobertura de librerías del enunciado tras la actualización

| Fase CRISP-DM | Librería exigida | Estado |
|---|---|---|
| Fase 2 — EDA | `dplyr` | ✅ Usado |
| Fase 2 — EDA | `ggplot2` | ✅ Integrado |
| Fase 2 — EDA | `summarytools` | ✅ Integrado |
| Fase 3 — Wrangling | `tidyverse` | ✅ Usado |
| Fase 3 — Wrangling | `dplyr` | ✅ Usado |
| Fase 3 — Wrangling | `stringr` | ✅ Integrado |
| Fase 3 — Wrangling | `tidyr` | ✅ Usado |
