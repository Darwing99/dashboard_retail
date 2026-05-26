# Dashboard de Análisis Retail — Documentación para Exposición

**Autor:** Darwing Hernandez  
**Tecnología:** R + Shiny  
**Fecha:** Mayo 2026

---

## 1. Introducción y Objetivo del Proyecto

Este proyecto es una aplicación web interactiva construida en **R Shiny** que permite analizar el comportamiento de compra de clientes en un negocio de retail en línea. Integra técnicas de **Business Intelligence**, **Análisis Exploratorio de Datos (EDA)**, **segmentación de clientes (RFM)** y **Machine Learning** en un único dashboard modular.

### Objetivo principal
Transformar datos transaccionales crudos en inteligencia de negocio accionable: identificar clientes valiosos, detectar clientes en riesgo de abandono y proponer estrategias de retención personalizadas por segmento.

### Preguntas de negocio que responde
- ¿Cuáles son los productos y países que generan más ingresos?
- ¿Cómo evolucionan las ventas en el tiempo?
- ¿Qué clientes son los más valiosos y cuáles están a punto de perderse?
- ¿Se puede predecir si un cliente seguirá activo o entrará en riesgo?

---

## 2. Dataset

| Atributo | Detalle |
|---|---|
| **Nombre** | Online Retail II (UCI / Kaggle) |
| **Tamaño** | ~94.8 MB, más de 500,000 transacciones |
| **Período** | 2 años de historia de compras |
| **Moneda** | Libras esterlinas (GBP £) |

### Columnas del dataset

| Campo | Descripción |
|---|---|
| `Invoice` | Código de factura (prefijo `C` = cancelación) |
| `StockCode` | Código de producto |
| `Description` | Nombre del producto |
| `Quantity` | Unidades compradas |
| `InvoiceDate` | Fecha y hora de la transacción |
| `Price` | Precio unitario en GBP |
| `CustomerID` | Identificador único del cliente |
| `Country` | País de origen de la compra |

---

## 3. Arquitectura de la Aplicación

La aplicación sigue una **arquitectura modular Shiny**, separando responsabilidades en capas:

```
dashboard_retail/
├── app.R              → Punto de entrada: orquesta la carga de todo
├── global.R           → Precomputación única: datos, modelo, RFM
├── ui.R               → Estructura visual (sidebar + 8 pestañas)
├── server.R           → Orquestación de módulos
├── R/                 → Funciones reutilizables
│   ├── data_prep.R    → ETL: carga, limpieza, enriquecimiento, RFM
│   ├── modelo.R       → Entrenamiento Random Forest
│   ├── plots.R        → Visualizaciones Plotly
│   ├── tablas.R       → Tablas interactivas DT
│   ├── helpers.R      → Utilidades, colores, formatos
│   └── ui_components.R→ Componentes UI reutilizables
└── modules/           → 8 módulos Shiny (uno por pestaña)
    ├── mod_inicio.R   → KPIs generales
    ├── mod_negocio.R  → F1: Análisis de negocio
    ├── mod_eda.R      → F2: Exploración de datos
    ├── mod_wrangling.R→ F3: Limpieza y transformación
    ├── mod_modelo.R   → F4: Entrenamiento del modelo
    ├── mod_evaluacion.R→ F5: Evaluación del modelo
    ├── mod_rfm.R      → F6: Segmentación RFM
    └── mod_datos.R    → F7: Datos crudos
```

### ¿Por qué arquitectura modular?
- **Mantenibilidad:** cada módulo es independiente y puede modificarse sin afectar los demás.
- **Escalabilidad:** agregar una nueva pestaña solo requiere crear un nuevo módulo.
- **Rendimiento:** `global.R` ejecuta el ETL y el entrenamiento **una sola vez** al iniciar la app; todos los módulos comparten esos resultados en memoria.

---

## 4. Pipeline de Datos (ETL)

El flujo de transformación completo ocurre en `global.R` al iniciar la app:

```
Datos crudos (CSV/Excel)
        ↓
   cargar_datos()          ← Lectura del archivo
        ↓
   limpiar_datos()         ← Filtrado y enriquecimiento
        ↓
   calcular_rfm()          ← Segmentación de clientes
        ↓
   entrenar_rf()           ← Modelo predictivo
        ↓
   Dashboard interactivo   ← 8 pestañas con resultados
```

### 4.1 Carga de datos (`cargar_datos`)
- Lee el archivo Excel o CSV desde `data/`.
- Si el archivo no está disponible, genera **datos simulados** de 10,000 registros para demostración.
- Normaliza los nombres de columnas.

### 4.2 Limpieza de datos (`limpiar_datos`)

**Filtros aplicados:**

| Criterio | Acción |
|---|---|
| Facturas con prefijo `"C"` | Eliminadas (cancelaciones) |
| `Quantity ≤ 0` | Eliminados |
| `Price ≤ 0` | Eliminados |
| `CustomerID` vacío | Eliminados |
| `StockCode` inválido | Eliminados |
| Duplicados exactos | Eliminados |

**Enriquecimiento:**

| Campo nuevo | Fórmula |
|---|---|
| `Revenue` | `Quantity × Price` |
| `Año`, `Mes`, `Trimestre` | Extraídos de `InvoiceDate` |
| `Día_Semana`, `Hora` | Extraídos de `InvoiceDate` |
| `Segmento_Precio` | Quintiles de precio → Económico / Básico / Estándar / Premium / Lujo |

---

## 5. Análisis Exploratorio (EDA)

La pestaña **F2 - EDA** presenta:

- **Resumen estadístico:** min, máx, promedio y mediana de Revenue, Quantity y Price.
- **Distribución de Revenue:** histograma para ver concentración y outliers.
- **Distribución de Cantidad:** volumen de unidades por transacción.
- **Heatmap Hora × Día de la semana:** identifica franjas horarias de mayor actividad.
- **Revenue por segmento de precio en el tiempo:** tendencia por categoría de producto.
- **Top 10 países:** cuáles generan más ingresos.

### Hallazgos típicos
- Las ventas tienen picos en **horas de oficina (9 am – 3 pm)** y los **martes y jueves**.
- La mayoría del revenue proviene de productos en los segmentos **Estándar y Premium**.
- El **Reino Unido** concentra la mayor parte de las ventas.

---

## 6. Data Wrangling

La pestaña **F3 - Wrangling** muestra de forma transparente todo el proceso de limpieza:

- Porcentaje de registros eliminados vs. conservados.
- Número de cancelaciones y su impacto en el dataset.
- Distribución del revenue antes y después de la limpieza.
- Distribución por segmentos de precio para validar la segmentación.

**Dato clave:** las cancelaciones representan aproximadamente el **5% del total** de facturas y se excluyen del análisis de ventas.

---

## 7. Análisis RFM (Segmentación de Clientes)

RFM es un método de segmentación basado en el comportamiento histórico de compra de cada cliente.

### Las 3 dimensiones RFM

| Dimensión | Definición | Cálculo |
|---|---|---|
| **Recencia (R)** | ¿Cuándo compró por última vez? | Días desde la última transacción |
| **Frecuencia (F)** | ¿Con qué frecuencia compra? | Número de facturas distintas |
| **Monetario (M)** | ¿Cuánto ha gastado en total? | Suma acumulada de Revenue |

### Scores RFM
Cada dimensión se convierte a un **score del 1 al 5** usando quintiles:
- **5** = mejor comportamiento (compró recientemente / compra mucho / gasta mucho)
- **1** = peor comportamiento

### Los 7 Segmentos de Clientes

| Segmento | Criterio | Significado estratégico |
|---|---|---|
| **Campeones** | R≥4, F≥4, M≥4 | Clientes VIP: compraron recientemente, compran mucho y gastan mucho |
| **Clientes Leales** | R≥3, F≥3 | Compran con regularidad y son recientes |
| **Clientes Recientes** | R≥4, F≤2 | Nuevos o esporádicos pero activos recientemente |
| **En Riesgo** | R≤2, F≥3 | Solían comprar seguido, pero no han vuelto |
| **No Puede Perder** | R≤2, F≤2, M≥3 | Bajo engagement pero alto valor histórico |
| **Perdidos** | R≤1 | Sin actividad reciente |
| **Otros** | Resto | No clasificados claramente |

### Variable objetivo para ML
A partir del RFM se define:
- `Es_Activo = "Activo"` → Recencia ≤ 90 días
- `Es_Activo = "En_Riesgo"` → Recencia > 90 días

Esta es la variable que el modelo de Machine Learning intentará predecir.

---

## 8. Modelo de Machine Learning — Random Forest

### ¿Por qué Random Forest?
- Robusto ante outliers y datos desbalanceados.
- No requiere normalización de variables.
- Proporciona importancia de variables interpretable.
- Excelente rendimiento en clasificación binaria.

### Configuración del modelo

| Parámetro | Valor | Descripción |
|---|---|---|
| `ntree` | 200 | Número de árboles en el bosque |
| `mtry` | 3 | Variables evaluadas por split |
| `importance` | TRUE | Calcula importancia de variables |
| Split | 75% / 25% | Train / Test |
| `seed` | 123 | Reproducibilidad |

### Variables predictoras (features)

| Variable | Descripción |
|---|---|
| `Recencia` | Días desde última compra (valor continuo) |
| `Frecuencia` | Número de transacciones (valor continuo) |
| `Monetario` | Revenue total acumulado (valor continuo) |
| `R_Score` | Score de recencia (1–5) |
| `F_Score` | Score de frecuencia (1–5) |
| `M_Score` | Score monetario (1–5) |

### Variable objetivo
`Es_Activo`: binaria → `"Activo"` o `"En_Riesgo"`

---

## 9. Evaluación del Modelo

La pestaña **F5 - Evaluación** presenta las métricas de desempeño en el conjunto de prueba (25% de datos no vistos durante el entrenamiento).

### Métricas clave

| Métrica | Definición | Interpretación |
|---|---|---|
| **Accuracy** | % de predicciones correctas | Correctitud general del modelo |
| **Sensibilidad** | % de "En_Riesgo" correctamente identificados | Capacidad de detectar churn |
| **Especificidad** | % de "Activos" correctamente identificados | Capacidad de confirmar clientes sanos |
| **AUC-ROC** | Área bajo la curva ROC (0.5–1.0) | Discriminación general del modelo |

### Curva ROC
La curva ROC muestra el trade-off entre **sensibilidad** y **1 - especificidad**. Un AUC cercano a 1.0 indica un modelo que distingue casi perfectamente entre clientes activos y en riesgo.

### Matriz de Confusión
Visualiza los 4 casos posibles de clasificación:
- **Verdadero Positivo (VP):** cliente en riesgo correctamente detectado
- **Verdadero Negativo (VN):** cliente activo correctamente identificado
- **Falso Positivo (FP):** cliente activo incorrectamente marcado como en riesgo
- **Falso Negativo (FN):** cliente en riesgo no detectado (el error más costoso)

---

## 10. Pestañas del Dashboard

| Pestaña | Contenido |
|---|---|
| **Inicio** | KPIs generales: clientes totales, revenue, transacciones, % cancelaciones |
| **F1 - Negocio** | Ventas en el tiempo, top países, top productos, análisis trimestral |
| **F2 - EDA** | Exploración estadística, heatmaps, distribuciones |
| **F3 - Wrangling** | Proceso de limpieza y enriquecimiento de datos |
| **F4 - Modelo** | Configuración y entrenamiento del Random Forest |
| **F5 - Evaluación** | Accuracy, AUC, ROC, matriz de confusión |
| **F6 - RFM** | Segmentación de clientes, scatter plots, estrategias de marketing |
| **F7 - Datos** | Tabla interactiva con 5,000 registros filtrable y descargable |

---

## 11. Stack Tecnológico

| Categoría | Librería | Propósito |
|---|---|---|
| **Framework web** | `shiny`, `shinydashboard` | App web interactiva |
| **Machine Learning** | `caret`, `randomForest`, `pROC` | Modelado y evaluación |
| **Visualización** | `plotly` | Gráficos interactivos |
| **Tablas** | `DT` (DataTables) | Tablas dinámicas con filtros |
| **Manipulación** | `dplyr`, `tidyr` | Transformación de datos |
| **Fechas** | `lubridate` | Parsing y operaciones de fechas |
| **Formatos** | `scales` | Formato de números y monedas |
| **Lectura** | `readxl` | Lectura de archivos Excel |

---

## 12. Flujo de Datos en la App

```
                    ┌─────────────────────────────┐
                    │         global.R             │
                    │  (ejecuta 1 vez al inicio)   │
                    │                              │
                    │  cargar_datos()              │
                    │       ↓                      │
                    │  limpiar_datos()             │
                    │       ↓                      │
                    │  calcular_rfm()              │
                    │       ↓                      │
                    │  entrenar_rf()               │
                    └──────────┬──────────────────┘
                               │ datos en memoria
              ┌────────────────┼────────────────────┐
              ↓                ↓                    ↓
        mod_negocio      mod_rfm            mod_evaluacion
        (retail_clean)   (rfm_data)         (modelo_resultado)
```

---

## 13. Estrategias de Marketing por Segmento

Generadas automáticamente en la pestaña RFM:

| Segmento | Estrategia recomendada | Canal | Prioridad |
|---|---|---|---|
| Campeones | Programas de lealtad VIP, acceso anticipado | Email + App | Alta |
| Clientes Leales | Descuentos exclusivos, encuestas de satisfacción | Email | Alta |
| Clientes Recientes | Onboarding, segunda compra con incentivo | Push / Email | Media |
| En Riesgo | Campaña de reactivación, oferta especial | Email + SMS | Alta |
| No Puede Perder | Atención personalizada, encuesta de abandono | Llamada / Email | Alta |
| Perdidos | Campaña de win-back o limpieza de base | Email masivo | Baja |
| Otros | Segmentación adicional requerida | — | Media |

---

## 14. Conclusiones

1. **El análisis RFM permite identificar con precisión el valor de cada cliente** sin necesidad de modelos complejos. Los segmentos "Campeones" y "En Riesgo" son los más críticos para la estrategia.

2. **El Random Forest logra predecir el estado del cliente (Activo / En Riesgo)** con buena precisión usando solo 6 variables derivadas del historial de compras.

3. **La arquitectura modular** permite que el dashboard sea fácilmente extensible: agregar una nueva pestaña de análisis es tan simple como crear un nuevo módulo sin tocar el resto del código.

4. **La precomputación en `global.R`** garantiza que el usuario del dashboard experimente tiempos de carga muy bajos, ya que el ETL y el entrenamiento se realizan una sola vez al iniciar la aplicación.

5. **La combinación de RFM + ML** es una práctica estándar en retail analytics y ofrece una base sólida para sistemas de recomendación y campañas de marketing personalizadas.

---

## 15. Posibles Mejoras Futuras

- Incorporar modelos de **predicción de valor de vida del cliente (CLV)**.
- Agregar un módulo de **recomendación de productos** por segmento.
- Conectar el dashboard a una **base de datos en tiempo real** (PostgreSQL, BigQuery).
- Implementar **alertas automáticas** cuando un cliente VIP entra en categoría de riesgo.
- Exportar los segmentos RFM directamente a herramientas de CRM (HubSpot, Salesforce).

---

*Documentación generada para exposición académica — Dashboard Retail Analytics en R Shiny*
