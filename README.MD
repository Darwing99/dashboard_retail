# Dashboard Retail - Análisis de Ventas y Comportamiento

**Autores:** 
- Gissela Jocelyne Grandez Berrios

- Darwing Hernandez Castellanos

- Daniel Alexander Cuellar

**Tipo:** Proyecto de Data Science - Dashboard Shiny Interactivo\
**Sector:** Retail - Análisis de ventas y predicción de comportamiento de clientes

------------------------------------------------------------------------

## Descripción del Proyecto

Dashboard interactivo en **R/Shiny** que realiza un análisis integral del comportamiento de compra de clientes en retail. Incluye:

- **Análisis exploratorio (EDA)** de datos de ventas
- **Data Wrangling**: limpieza y enriquecimiento
- **Modelado predictivo**: Random Forest para identificar clientes activos
- **Evaluación del modelo**: métricas, ROC, matriz de confusión
- **Análisis RFM**: segmentación de clientes por Recencia, Frecuencia, Monetario
- **Visualizaciones interactivas**: con Plotly y Shiny
- **Tablas interactivas**: con DT (DataTables)

------------------------------------------------------------------------

## Estructura del Proyecto

```         
retail_dashboard/
├── app.R                      # Punto de entrada principal
├── global.R                   # Config global, cargas, precomputación
├── ui.R                       # Interfaz de usuario
├── server.R                   # Lógica del servidor
├── README.md                  # Este archivo
├── renv.lock                  # Versiones exactas de paquetes
│
├── R/                         # Funciones personalizadas
│   ├── helpers.R              # Colores, funciones de formato
│   ├── data_prep.R            # Carga, limpieza, RFM
│   ├── modelo.R               # Entrenamiento RF, evaluación
│   ├── plots.R                # Gráficos con Plotly
│   ├── tablas.R               # Tablas con DT
│   └── ui_components.R        # Componentes reutilizables UI
│
├── data/
│   └── online_retail_II.xlsx  # Dataset de retail (descargar)
│
├── www/
│   └── custom.css             # Estilos personalizados
│
└── tests/
    ├── test_data_prep.R       # Tests para funciones de datos
    └── test_modelo.R          # Tests para modelo
```

------------------------------------------------------------------------

## Instalación y Configuración

### Requisitos Previos

- **R \>= 4.0.0** (descargar desde [r-project.org](https://www.r-project.org))
- **RStudio** (recomendado)
- Conexión a internet (para descargar paquetes)

### 2️⃣ Clonar/Descargar el Proyecto

``` bash
git clone https://github.com/tu-usuario/retail_dashboard.git
cd retail_dashboard
```

O descargar el ZIP y extraer en tu directorio de trabajo.

### 3️⃣ Instalar Dependencias

Opción A: **Automática con renv** (recomendado)

``` r
# En RStudio, ejecutar:
renv::restore()  # Instala versiones exactas del archivo renv.lock
```

Opción B: **Manual con install.packages**

``` r
# En R/RStudio, ejecutar:
paquetes <- c(
  "shiny", "shinydashboard", "DT", "plotly",
  "tidyverse", "tibble", "lubridate", "scales",
  "caret", "randomForest", "pROC", "readxl", "corrplot",
  "summarytools", "stringr", "ggplot2"
)
install.packages(paquetes)
```

### 4️⃣ Descargar el Dataset

1.  Ir a: <https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci>
2.  Descargar `online_retail_II.xlsx`
3.  Colocar en: `retail_dashboard/data/`

> **Nota:** El dashboard también funciona con datos simulados si el archivo no existe.

### 5️⃣ Ejecutar la Aplicación

``` r
# Opción 1: Desde RStudio
setwd("retail_dashboard")
shiny::runApp()

# Opción 2: Desde terminal/consola R
shiny::runApp("retail_dashboard")

# Opción 3: Desde línea de comandos
Rscript -e "shiny::runApp('retail_dashboard')"
```

Se abrirá un navegador en `http://localhost:3838/`

------------------------------------------------------------------------

## 📑 Descripción de Pestañas

### 1. **📊 Inicio**

- KPIs principales
- Resumen general del proyecto
- Navegación guiada

### 2. **🏢 F1: Negocio**

- Ventas a lo largo del tiempo (serie temporal)
- Top 10 países por revenue
- Información general del dataset

### 3. **📈 F2: Datos (EDA)**

- Resumen estadístico (min, máx, media, mediana)
- Distribución de revenue e histograma de cantidad (Plotly)
- **Histograma de Revenue con ggplot2** (hasta percentil 95)
- **Boxplot de Revenue por Segmento de Precio con ggplot2**
- **Resumen estadístico detallado con summarytools::dfSummary()**
- Heatmap de actividad Hora × Día de la semana
- Revenue por segmento de precio en el tiempo
- Análisis por país (Top 10)

### 4. **🔧 F3: Wrangling**

- Detalles de limpieza
- Cancelaciones removidas
- Distribución de revenue (sin outliers)
- Segmentación de precios

### 5. **🧠 F4: Modelado**

- Random Forest (200 árboles)
- Importancia de variables
- Distribución train/test
- Parámetros del modelo

### 6. **📋 F5: Evaluación**

- Métricas: Accuracy, Sensitivity, Specificity, AUC
- Curva ROC
- Matriz de confusión
- Interpretación de resultados

### 7. **🎯 F6: RFM**

- Segmentación de clientes (7 segmentos)
- Gráficos: pie, barras, scatter, boxplot
- Tabla de estrategias por segmento
- Top clientes

### 8. **📑 F7: Datos Raw**

- Vista interactiva de 5,000 registros
- Filtros y búsqueda
- Descarga de datos

------------------------------------------------------------------------

## 🔬 Flujo del Análisis

```         
1. CARGA DE DATOS (global.R)
   └── online_retail_II.xlsx / datos simulados

2. LIMPIEZA (data_prep.R) — usando stringr + dplyr
   ├── Remover cancelaciones (stringr::str_detect)
   ├── Validar valores positivos
   ├── Parse de fechas (lubridate)
   └── Enriquecimiento (Revenue, Segmento_Precio)

3. CÁLCULO RFM (data_prep.R) — usando dplyr + tidyr
   ├── Recencia (días desde última compra)
   ├── Frecuencia (número de compras)
   ├── Monetario (valor total gastado)
   └── Segmentación (7 segmentos de cliente)

4. EDA (mod_eda.R) — usando ggplot2 + summarytools + plotly
   ├── Histograma Revenue (ggplot2)
   ├── Boxplot por Segmento (ggplot2)
   ├── Resumen dfSummary (summarytools)
   └── Heatmaps y distribuciones (plotly)

5. ENTRENAMIENTO MODELO (modelo.R) — usando caret + randomForest
   ├── Split 75/25 train/test
   ├── Random Forest (ntree=200, mtry=3)
   └── Evaluación: Accuracy, AUC, Confusion Matrix

6. VISUALIZACIÓN (plots.R) — usando plotly
   ├── Gráficos de negocio
   ├── Gráficos del modelo
   └── Gráficos RFM

7. TABLAS (tablas.R) — usando DT
   ├── Tabla de recomendaciones
   ├── Tabla RFM de clientes
   └── Tabla raw de transacciones
```

------------------------------------------------------------------------

## 🔧 Configuración Avanzada

### Cambiar Dataset

Editar en `global.R`:

``` r
# Cambiar archivo de entrada
retail_raw <- cargar_datos(archivo = "ruta/a/tu/archivo.xlsx")
```

### Ajustar Parámetros del Modelo

Editar en `R/modelo.R`:

``` r
modelo_rf <- randomForest::randomForest(
  Es_Activo ~ .,
  data = train_data,
  ntree = 300,    # Cambiar número de árboles
  mtry = 4,       # Cambiar variables por split
  importance = TRUE
)
```

### Personalizar Colores

Editar en `R/helpers.R`:

``` r
COLORS <- list(
  primary   = "#1A5276",  # Color principal
  success   = "#2ECC71",  # Verde
  danger    = "#E74C3C",  # Rojo
  # ... más colores
)
```

------------------------------------------------------------------------

## 📊 RFM Segmentation

Los clientes se clasifican en **7 segmentos**:

| Segmento | Descripción | Acción |
|------------------------|-----------------------------|--------------------|
| **Campeones** | R↑ F↑ M↑ | VIP: acceso anticipado, descuentos exclusivos |
| **Clientes Leales** | R≥3 F≥3 | Upselling, programa de puntos |
| **Clientes Recientes** | R↑ F↓ | Onboarding: emails, guías, oferta especial |
| **En Riesgo** | R↓ F≥3 | Reactivación urgente: -15-25% descuento |
| **No Puede Perder** | R↓ F↓ M↑ | Encuesta, oferta especial, llamada |
| **Perdidos** | R↓↓ | Winback email; si no responde, parar |
| **Otros** | Resto | Newsletter informativo |

------------------------------------------------------------------------

## 🎯 Métricas del Modelo

- **Accuracy**: Proporción de predicciones correctas
- **Sensitivity**: % de clientes Activos identificados correctamente
- **Specificity**: % de clientes En_Riesgo identificados correctamente
- **AUC-ROC**: Capacidad discriminativa (0.5 = aleatorio, 1 = perfecto)

------------------------------------------------------------------------

## 🐛 Troubleshooting

### Error: "File not found"

``` r
# Asegúrate de estar en el directorio correcto
setwd("path/to/retail_dashboard")
```

### Error: "Package not found"

``` r
# Instalar paquete faltante
install.packages("nombre_paquete")
```

### Error: "Sheet not found"

- Verifica que `online_retail_II.xlsx` tenga una hoja llamada "page"
- El dashboard crea datos simulados si el archivo no existe

### Aplicación lenta

- Aumentar RAM disponible en RStudio
- Reducir n_filas en `dt_datos_raw()` en `R/tablas.R`

------------------------------------------------------------------------

## 📚 Librerías Utilizadas

| Librería       | Versión    | Uso                                        |
|----------------|------------|--------------------------------------------|
| shiny          | >= 1.7.0   | Framework web interactivo                  |
| shinydashboard | >= 0.7.2   | Plantilla dashboard                        |
| plotly         | >= 4.10.0  | Gráficos interactivos (EDA, negocio, RFM)  |
| ggplot2        | >= 3.4.0   | Histograma y boxplot estáticos (EDA F2)    |
| tidyverse      | >= 1.3.1   | Ecosistema data wrangling                  |
| stringr        | >= 1.5.0   | Limpieza de texto (detección cancelaciones)|
| tidyr          | >= 1.3.0   | Pivotado de tablas (matriz de confusión)   |
| dplyr          | >= 1.1.0   | Transformación y agregación de datos       |
| lubridate      | >= 1.8.0   | Parsing y extracción de fechas             |
| summarytools   | >= 1.0.0   | Resumen estadístico descriptivo (EDA F2)   |
| randomForest   | >= 4.7     | Modelo de clasificación Random Forest      |
| caret          | >= 6.0     | Split train/test y métricas de evaluación  |
| pROC           | >= 1.18    | Curva ROC y cálculo de AUC                 |
| DT             | >= 0.20    | Tablas interactivas con filtros            |
| scales         | >= 1.2.0   | Formato de números y monedas               |
| readxl         | >= 1.4.0   | Lectura de archivos Excel (.xlsx)          |

------------------------------------------------------------------------

## 🔐 Desplegar en Producción

### Opción 1: Shiny Server (Linux)

``` bash
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.18.1004-amd64.deb
sudo gdebi shiny-server-1.5.18.1004-amd64.deb
```

### Opción 2: shinyapps.io

``` r
# En RStudio
install.packages('rsconnect')
rsconnect::deployApp('retail_dashboard')
```

### Opción 3: Docker

``` dockerfile
FROM rocker/r-shiny:latest
RUN R -e "install.packages(c('shiny', 'shinydashboard', ...))"
COPY retail_dashboard /srv/shiny-server/app
```

------------------------------------------------------------------------

## Licencia

Este proyecto es de uso académico y educativo.

------------------------------------------------------------------------

## Autores
- Gissela Jocelyne Grandez Berrios

- Darwing Hernandez Castellanos

- Daniel Alexander Cuellar

------------------------------------------------------------------------

##Soporte

Para preguntas o reportar bugs, crear un issue en el repositorio.

------------------------------------------------------------------------

**Última actualización:** Mayo 2026
