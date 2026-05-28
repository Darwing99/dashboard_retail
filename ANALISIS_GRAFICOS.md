# Análisis del Dataset y Gráficos — Dashboard Retail

**Proyecto:** Dashboard Retail - Análisis de Ventas y Comportamiento  
**Autores:** Gissela Jocelyne Grandez Berrios · Darwing Hernandez Castellanos · Daniel Alexander Cuellar  
**Fecha:** Mayo 2026

---

## ¿Sobre qué trata el dataset?

Es la base de datos de una **tienda online de regalos y decoración del hogar del Reino Unido**, con más de **500,000 transacciones registradas entre 2009 y 2011**. Vende principalmente a mayoristas en Europa. Cada fila representa una línea de factura: qué producto se compró, cuántas unidades, a qué precio, cuándo y desde qué país.

| Atributo | Detalle |
|---|---|
| **Fuente** | UCI Machine Learning Repository / Kaggle |
| **Tamaño** | ~500,000 transacciones, 91 MB |
| **Período** | Diciembre 2009 – Diciembre 2011 |
| **Moneda** | Libras esterlinas (GBP £) |
| **Sector** | Retail online — regalos y decoración del hogar |
| **Mercado** | Principalmente Reino Unido, con presencia en Europa |

---

## Análisis por gráfico

---

### Tab F1 — Negocio

---

#### 1. Ventas a lo largo del tiempo (gráfico de línea con área)

Muestra la **serie diaria de ingresos totales** a lo largo de los dos años del dataset. Se observa una tendencia creciente con un pico marcado hacia finales de año (Q4), típico de la temporada navideña en retail de regalos. Las caídas bruscas indican fines de semana o días sin operación comercial.

> **Conclusión:** El negocio tiene estacionalidad fuerte en Q4 y crece año sobre año.

---

#### 2. Top 10 países por revenue (barras horizontales)

El **Reino Unido domina de forma abrumadora** el revenue total, representando aproximadamente el 80-85% de los ingresos. Los países siguientes — Países Bajos, Irlanda, Alemania, Francia — generan una fracción comparativamente pequeña. Confirma que el negocio opera principalmente en el mercado doméstico.

> **Conclusión:** La estrategia de expansión internacional tiene amplio margen de crecimiento fuera del Reino Unido.

---

#### 3. Revenue por trimestre agrupado por año (barras agrupadas)

Compara Q1 a Q4 entre los dos años disponibles. El **Q4 es consistentemente el trimestre más alto** en ambos años, y el crecimiento interanual es más visible en Q3 y Q4. Permite detectar tanto la estacionalidad como el ritmo de crecimiento del negocio.

> **Conclusión:** Los esfuerzos de marketing y logística deben anticipar el pico de Q4.

---

#### 4. Revenue por día de la semana (barras verticales)

Los **días de martes a jueves concentran la mayor actividad de ventas**. El domingo prácticamente no registra transacciones. Este patrón refleja el perfil B2B del negocio: los mayoristas realizan sus pedidos en días laborales de mitad de semana.

> **Conclusión:** Las campañas y promociones deben lanzarse entre lunes y miércoles para aprovechar el pico de actividad.

---

#### 5. Top 10 productos por revenue (barras horizontales)

Identifica los **productos estrella del catálogo**, generalmente artículos de decoración con alto volumen de unidades vendidas. Es la base para decisiones de inventario, reposición prioritaria y estrategias de cross-selling con clientes de alto valor.

> **Conclusión:** Una pequeña fracción del catálogo genera la mayor parte de los ingresos (principio de Pareto).

---

### Tab F2 — EDA (Análisis Exploratorio de Datos)

---

#### 6. Histograma de Revenue por transacción (Plotly)

La distribución está **fuertemente sesgada a la derecha**: la gran mayoría de transacciones son de bajo valor (£1–£50), pero existen algunas de alto valor que elevan el promedio considerablemente. Se aplica un corte en el percentil 95 para eliminar los outliers extremos y mejorar la legibilidad.

> **Conclusión:** La mediana es mucho más representativa que la media para este dataset.

---

#### 7. Histograma de unidades por transacción (Plotly)

Similar al histograma de revenue: la mayoría de pedidos contienen pocas unidades (1–12), pero existen pedidos mayoristas de gran volumen. La distribución tiene forma similar a una Poisson, típica del comportamiento de compra en retail.

> **Conclusión:** Los pedidos de gran volumen son la excepción, no la regla, y corresponden a clientes mayoristas específicos.

---

#### 8. Heatmap Hora × Día de la semana

Visualiza la **intensidad de transacciones en una grilla de 7 días × 24 horas**. Las celdas más oscuras se concentran entre las 9 am y las 3 pm de lunes a jueves. Confirma que los clientes son empresas que operan en horario comercial, no consumidores individuales.

> **Conclusión:** El canal de atención y soporte debe priorizarse en horario de oficina entre semana.

---

#### 9. Revenue por segmento de precio en el tiempo (multilínea)

Traza cómo evoluciona el ingreso de cada categoría de precio (Económico, Básico, Estándar, Premium, Lujo) a lo largo del tiempo. El **segmento Estándar suele dominar**, con picos en todos los segmentos al acercarse el Q4. Permite identificar qué categorías crecen o decrecen.

> **Conclusión:** Los segmentos Premium y Estándar son los motores del crecimiento interanual.

---

#### 10. Histograma de Revenue con ggplot2

Mismo análisis que el gráfico #6 pero construido con `ggplot2::geom_histogram()`. Confirma la **asimetría positiva** de la distribución: la mediana es mucho más baja que la media, indicando que unos pocos pedidos de alto valor sesgan el promedio hacia arriba.

> **Conclusión:** Usar la mediana como métrica central es más honesto que el promedio para reportar el ingreso típico por transacción.

---

#### 11. Boxplot de Revenue por Segmento con ggplot2

Construido con `ggplot2::geom_boxplot()`, muestra la **dispersión y presencia de outliers en cada categoría de precio**. Los segmentos Premium y Lujo presentan mayor dispersión (cajas más amplias y más valores atípicos), mientras que Económico y Básico son más homogéneos en sus montos.

> **Conclusión:** El segmento Premium es el más volátil en comportamiento de gasto; requiere análisis individualizado por cliente.

---

### Tab F3 — Wrangling

---

#### 12. Distribución de Revenue post-limpieza (Plotly)

La misma visualización del histograma de revenue, pero en el contexto del proceso de limpieza. Muestra cómo quedó la distribución **después de eliminar cancelaciones, cantidades negativas, precios nulos y registros sin CustomerID**. Sirve como validación de que la limpieza no distorsionó la distribución original.

> **Conclusión:** La limpieza eliminó el 20–30% de registros sin afectar la forma general de la distribución.

---

#### 13. Revenue por Segmento de Precio (barras)

Valida que la segmentación de precios tiene sentido económico: cada categoría agrupa productos con comportamiento diferente. El segmento Económico tiene muchas transacciones de poco valor; Premium tiene pocas pero de alto impacto en el revenue total.

> **Conclusión:** La variable `Segmento_Precio` creada en el wrangling es una feature útil y bien diferenciada para el modelo.

---

### Tab F4 — Modelado

---

#### 14. Importancia de variables — Random Forest (barras horizontales)

Muestra el **MeanDecreaseGini** de cada variable predictora del modelo. Generalmente **Recencia y Monetario lideran la importancia**, seguidos de Frecuencia. Los scores derivados (R_Score, F_Score, M_Score) aportan menos porque son transformaciones discretas de las métricas continuas originales.

> **Conclusión:** La recencia del cliente es el mejor predictor de si seguirá activo o entrará en riesgo de abandono.

---

#### 15. Distribución de clases train vs test (barras apiladas)

Verifica que el **split 75/25 estratificado mantuvo la misma proporción de clases** (Activo vs En_Riesgo) tanto en entrenamiento como en prueba. Si ambas barras tienen proporciones similares, el muestreo con `caret::createDataPartition()` funcionó correctamente.

> **Conclusión:** El modelo se entrenó y evaluó sobre datos representativos del balance real de clases.

---

### Tab F5 — Evaluación

---

#### 16. Curva ROC

Grafica la **Sensibilidad (TPR) frente a 1 - Especificidad (FPR)** del modelo Random Forest. Mientras más se aproxime la curva a la esquina superior izquierda, y mayor sea el AUC, mejor discrimina el modelo entre clientes activos y en riesgo. La línea diagonal punteada representa una clasificación completamente aleatoria (AUC = 0.5).

> **Conclusión:** Un AUC superior a 0.85 indica que el modelo tiene una capacidad discriminativa muy buena para este problema.

---

#### 17. Matriz de Confusión (heatmap)

Visualiza los **4 cuadrantes de clasificación**: Verdadero Positivo (VP), Verdadero Negativo (VN), Falso Positivo (FP) y Falso Negativo (FN). Los colores más intensos en la diagonal principal indican buenas predicciones. El error más costoso para el negocio es el **Falso Negativo**: un cliente en riesgo que el modelo no detecta y que termina perdiéndose sin intervención.

> **Conclusión:** Minimizar los Falsos Negativos debe ser el criterio de optimización principal en este contexto de negocio.

---

### Tab F6 — RFM (Segmentación de Clientes)

---

#### 18. Distribución de segmentos (gráfico donut)

Muestra qué **porcentaje de clientes pertenece a cada uno de los 7 segmentos RFM**. Idealmente los segmentos "Campeones" y "Leales" suman una parte significativa. Si "Perdidos" o "En Riesgo" dominan la distribución, el negocio enfrenta un problema estructural de retención de clientes.

> **Conclusión:** La distribución de segmentos es el diagnóstico de salud de la base de clientes.

---

#### 19. Revenue por segmento (barras)

Aunque los "Campeones" pueden ser un segmento pequeño en número de clientes, generalmente aportan **la mayor parte del revenue total**. Este gráfico hace visible el principio de Pareto aplicado a clientes: el 20% genera el 80% de los ingresos.

> **Conclusión:** Proteger a los Campeones y Leales de la deserción debe ser la prioridad número uno de cualquier estrategia de retención.

---

#### 20. Activos vs En Riesgo por segmento (barras apiladas 100%)

Para cada segmento muestra **qué proporción está activa (compró en los últimos 90 días) y cuál está en riesgo**. Un segmento "Leales" con alta proporción En_Riesgo es una señal de alerta crítica: clientes que compraban con frecuencia están dejando de hacerlo.

> **Conclusión:** Este gráfico convierte el RFM en una herramienta de acción inmediata, identificando qué segmentos requieren campaña de reactivación urgente.

---

#### 21. Scatter Frecuencia vs Monetario

Cada punto representa un cliente, coloreado por su segmento. Los "Campeones" se agrupan en la **esquina superior derecha** (alta frecuencia + alto gasto total). Permite identificar visualmente la separación entre segmentos y detectar clientes que podrían haber sido mal clasificados.

> **Conclusión:** La separación visual de los segmentos valida que los criterios de clasificación RFM tienen coherencia estadística.

---

#### 22. Boxplot de Recencia por segmento

Muestra **cuántos días lleva sin comprar** el conjunto de clientes de cada segmento. Los "Perdidos" tienen la recencia más alta (llevan más tiempo ausentes) y "Campeones" la más baja. La amplitud de la caja refleja la variabilidad dentro del segmento.

> **Conclusión:** La recencia separa claramente los segmentos, confirmando que es la variable más discriminante del modelo.

---

#### 23. Heatmap R_Score × F_Score coloreado por M_Score

Una vista tridimensional del RFM comprimida en 2D. La celda de la esquina superior derecha (R=5, F=5) debería tener el **M_Score más alto** (color verde intenso en la escala RdYlGn). Permite verificar si los tres ejes del RFM están correlacionados o si existen clientes frecuentes que paradójicamente gastan poco.

> **Conclusión:** Si la correlación R-F-M es fuerte, el modelo tendrá alta predictibilidad. Si hay ruido, puede indicar comportamientos de compra atípicos que merecen análisis adicional.

---

## Resumen ejecutivo de hallazgos

| # | Gráfico | Hallazgo principal |
|---|---|---|
| 1 | Ventas en el tiempo | Crecimiento con pico estacional en Q4 |
| 2 | Top países | Reino Unido concentra +80% del revenue |
| 3 | Revenue trimestral | Q4 domina en ambos años |
| 4 | Ventas por día | Martes–Jueves son los días de mayor actividad |
| 5 | Top productos | Pocos productos generan la mayor parte del ingreso |
| 6-7 | Histogramas | Distribuciones sesgadas a la derecha (outliers altos) |
| 8 | Heatmap hora×día | Actividad concentrada en horario de oficina |
| 9 | Revenue por segmento tiempo | Estándar y Premium lideran el crecimiento |
| 10-11 | ggplot2 (histograma + boxplot) | Asimetría confirmada; Premium más volátil |
| 12-13 | Post-wrangling | Limpieza no distorsionó la distribución |
| 14 | Importancia variables | Recencia es el predictor más importante |
| 15 | Distribución clases | Split estratificado balanceado |
| 16 | Curva ROC | AUC >0.85 — modelo con buena discriminación |
| 17 | Matriz confusión | Minimizar Falsos Negativos es prioritario |
| 18 | Donut segmentos | Diagnóstico de salud de la base de clientes |
| 19 | Revenue por segmento | Campeones generan el mayor revenue |
| 20 | Activos vs En Riesgo | Identifica segmentos con urgencia de reactivación |
| 21 | Scatter F vs M | Separación visual valida los segmentos RFM |
| 22 | Boxplot recencia | Recencia separa segmentos con claridad |
| 23 | Heatmap RFM scores | Correlación entre las 3 dimensiones RFM |

---

*Documento generado como parte del proyecto final de Data Science — Metodología CRISP-DM aplicada al sector Retail.*
