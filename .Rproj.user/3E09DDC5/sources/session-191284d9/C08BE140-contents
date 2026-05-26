# =============================================================================
# R/PLOTS.R - FUNCIONES DE VISUALIZACIÓN CON PLOTLY
# =============================================================================
# Encapsula gráficos reutilizables con tema corporativo consistente

# =========== TEMA CORPORATIVO ===========
#' Aplica estilo corporativo a gráficos Plotly
#'
#' @param p objeto plotly
#' @return plotly con tema aplicado
tema_corporativo <- function(p) {
  p %>%
    plotly::layout(
      font = list(family = "Segoe UI, sans-serif", size = 12, color = COLORS$dark),
      plot_bgcolor = COLORS$light_gray,
      paper_bgcolor = "white",
      margin = list(l = 60, r = 40, b = 40, t = 40)
    )
}

# =========== GRÁFICOS DE NEGOCIO ===========

#' Gráfico de ventas por mes
plot_ventas_mes <- function(clean) {
  dat <- clean %>%
    dplyr::group_by(Fecha) %>%
    dplyr::summarise(Revenue = sum(Revenue, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(Fecha)
  
  plotly::plot_ly(
    dat,
    x = ~Fecha,
    y = ~Revenue,
    type = "scatter",
    mode = "lines",
    fill = "tozeroy",
    line = list(color = COLORS$primary, width = 2.5),
    fillcolor = COLORS$success_light,
    hovertemplate = "<b>%{x|%d/%m/%Y}</b><br>Revenue: £%{y:,.0f}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Fecha"),
      yaxis = list(title = "Revenue (£)", tickformat = ",.0f")
    )
}

#' Gráfico de top países por revenue
plot_top_paises <- function(clean, top_n = 10) {
  dat <- clean %>%
    dplyr::group_by(Country) %>%
    dplyr::summarise(Revenue = sum(Revenue, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(dplyr::desc(Revenue)) %>%
    dplyr::slice(1:top_n)
  
  plotly::plot_ly(
    dat,
    x = ~reorder(Country, Revenue),
    y = ~Revenue,
    type = "bar",
    marker = list(color = COLORS$info),
    hovertemplate = "<b>%{x}</b><br>Revenue: £%{y:,.0f}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "País"),
      yaxis = list(title = "Revenue Total (£)", tickformat = ",.0f"),
      showlegend = FALSE
    )
}

#' Distribución de revenue
plot_revenue_dist <- function(clean) {
  # Excluir outliers (p95)
  limite <- quantile(clean$Revenue, 0.95, na.rm = TRUE)
  dat <- clean %>% dplyr::filter(Revenue < limite)
  
  plotly::plot_ly(
    dat,
    x = ~Revenue,
    type = "histogram",
    nbinsx = 60,
    marker = list(color = COLORS$success, opacity = 0.8),
    hovertemplate = "Revenue: £%{x:.2f}<br>Frecuencia: %{y}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Revenue por Transacción (£)"),
      yaxis = list(title = "Frecuencia")
    )
}

#' Segmentos de precio
plot_segmento_precio <- function(clean) {
  dat <- clean %>%
    dplyr::group_by(Segmento_Precio) %>%
    dplyr::summarise(
      N = dplyr::n(),
      Revenue = sum(Revenue, na.rm = TRUE),
      .groups = "drop"
    )
  
  plotly::plot_ly(
    dat,
    x = ~factor(Segmento_Precio, 
                levels = c("Económico", "Básico", "Estándar", "Premium", "Lujo")),
    y = ~Revenue,
    type = "bar",
    color = ~Segmento_Precio,
    colors = "Set2",
    hovertemplate = "<b>%{x}</b><br>Revenue: £%{y:,.0f}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Segmento de Precio"),
      yaxis = list(title = "Revenue Total (£)", tickformat = ",.0f"),
      showlegend = FALSE
    )
}

# =========== GRÁFICOS DEL MODELO ===========

#' Importancia de variables Random Forest
plot_importancia_modelo <- function(modelo_rf) {
  imp_df <- randomForest::importance(modelo_rf) %>%
    as.data.frame() %>%
    tibble::rownames_to_column("Variable") %>%
    dplyr::arrange(dplyr::desc(MeanDecreaseGini))
  
  plotly::plot_ly(
    imp_df,
    x = ~MeanDecreaseGini,
    y = ~reorder(Variable, MeanDecreaseGini),
    type = "bar",
    orientation = "h",
    marker = list(color = COLORS$info),
    hovertemplate = "<b>%{y}</b><br>Importancia: %{x:.2f}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Mean Decrease Gini"),
      yaxis = list(title = "")
    )
}

#' Distribución de clases train/test
plot_distribucion_clases <- function(train_data, test_data) {
  dat <- dplyr::bind_rows(
    train_data %>% dplyr::mutate(Conjunto = "Entrenamiento"),
    test_data %>% dplyr::mutate(Conjunto = "Prueba")
  ) %>%
    dplyr::count(Conjunto, Es_Activo)
  
  plotly::plot_ly(
    dat,
    x = ~Conjunto,
    y = ~n,
    color = ~Es_Activo,
    type = "bar",
    colors = c(COLORS$danger, COLORS$success),
    hovertemplate = "<b>%{x}</b><br>%{fullData.name}: %{y}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      barmode = "stack",
      xaxis = list(title = "Conjunto"),
      yaxis = list(title = "Registros"),
      legend = list(x = 0.02, y = 0.98)
    )
}

# =========== GRÁFICOS DE EVALUACIÓN ===========

#' Curva ROC
plot_roc <- function(roc_obj, auc_val) {
  roc_df <- data.frame(
    FPR = 1 - roc_obj$specificities,
    TPR = roc_obj$sensitivities
  )
  
  plotly::plot_ly(
    roc_df,
    x = ~FPR,
    y = ~TPR,
    type = "scatter",
    mode = "lines",
    line = list(color = COLORS$danger, width = 2.5),
    name = paste0("RF (AUC = ", auc_val, ")"),
    hovertemplate = "FPR: %{x:.3f}<br>TPR: %{y:.3f}<extra></extra>"
  ) %>%
    plotly::add_lines(
      x = c(0, 1),
      y = c(0, 1),
      line = list(dash = "dash", color = "gray"),
      name = "Aleatoria"
    ) %>%
    tema_corporativo() %>%
    plotly::layout(
      title = paste("Curva ROC | AUC =", auc_val),
      xaxis = list(title = "1 - Especificidad (FPR)", range = c(0, 1)),
      yaxis = list(title = "Sensibilidad (TPR)", range = c(0, 1)),
      showlegend = TRUE
    )
}

#' Matriz de confusión como heatmap
plot_confusion_matrix <- function(conf_matrix, acc_pct) {
  cm <- as.data.frame(conf_matrix$table)
  
  plotly::plot_ly(
    x = cm$Reference,
    y = cm$Prediction,
    z = cm$Freq,
    type = "heatmap",
    colorscale = list(c(0, COLORS$light_red), c(1, COLORS$primary)),
    showscale = TRUE,
    text = cm$Freq,
    texttemplate = "%{text}",
    hovertemplate = "Real: %{x}<br>Predicho: %{y}<br>N: %{z}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      title = paste("Matriz de Confusión | Accuracy:", acc_pct),
      xaxis = list(title = "Clase Real"),
      yaxis = list(title = "Clase Predicha")
    )
}

# =========== GRÁFICOS RFM ===========

#' Segmentos de cliente - pie chart
plot_segmentos_pie <- function(rfm_data) {
  dat <- rfm_data %>% dplyr::count(Segmento_Cliente)
  
  plotly::plot_ly(
    dat,
    labels = ~Segmento_Cliente,
    values = ~n,
    type = "pie",
    hole = 0.4,
    textinfo = "label+percent",
    hovertemplate = "%{label}: %{value} clientes<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(showlegend = TRUE)
}

#' Revenue por segmento
plot_segmentos_revenue <- function(rfm_data) {
  dat <- rfm_data %>%
    dplyr::group_by(Segmento_Cliente) %>%
    dplyr::summarise(Revenue = sum(Monetario, na.rm = TRUE), .groups = "drop") %>%
    dplyr::arrange(dplyr::desc(Revenue))
  
  plotly::plot_ly(
    dat,
    x = ~reorder(Segmento_Cliente, Revenue),
    y = ~Revenue,
    type = "bar",
    color = ~Segmento_Cliente,
    colors = "Set1",
    hovertemplate = "<b>%{x}</b><br>Revenue: £%{y:,.0f}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Segmento"),
      yaxis = list(title = "Revenue Total (£)", tickformat = ",.0f"),
      showlegend = FALSE
    )
}

#' Scatter Frecuencia vs Monetario
plot_rfm_scatter <- function(rfm_data) {
  # Excluir outliers (p95)
  limite <- quantile(rfm_data$Monetario, 0.95, na.rm = TRUE)
  dat <- rfm_data %>% dplyr::filter(Monetario < limite)
  
  plotly::plot_ly(
    dat,
    x = ~Frecuencia,
    y = ~Monetario,
    color = ~Segmento_Cliente,
    type = "scatter",
    mode = "markers",
    marker = list(size = 6, opacity = 0.6),
    colors = "Set1",
    text = ~paste(
      "Cliente:", CustomerID,
      "<br>Recencia:", Recencia, "días",
      "<br>Frecuencia:", Frecuencia,
      "<br>Monetario: £", round(Monetario, 0)
    ),
    hovertemplate = "%{text}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Frecuencia (Nro. Compras)"),
      yaxis = list(title = "Monetario (£)", tickformat = ",.0f")
    )
}

#' Boxplot Recencia por segmento
plot_rfm_boxplot <- function(rfm_data) {
  plotly::plot_ly(
    rfm_data,
    y = ~Recencia,
    color = ~Segmento_Cliente,
    type = "box",
    colors = "Set2",
    boxmean = "sd",
    hovertemplate = "%{text}<extra></extra>"
  ) %>%
    tema_corporativo() %>%
    plotly::layout(
      xaxis = list(title = "Segmento"),
      yaxis = list(title = "Recencia (días desde última compra)"),
      showlegend = FALSE
    )
}

# =========== GRÁFICOS ADICIONALES DE NEGOCIO ===========

#' Revenue por día de la semana
plot_ventas_dia_semana <- function(clean) {
  dias_orden <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  dias_es    <- c("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")

  dat <- clean |>
    dplyr::group_by(DiaSemana) |>
    dplyr::summarise(
      Revenue       = sum(Revenue, na.rm = TRUE),
      Transacciones = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      DiaSemana = factor(DiaSemana, levels = dias_orden, labels = dias_es)
    ) |>
    dplyr::arrange(DiaSemana)

  plotly::plot_ly(
    dat,
    x          = ~DiaSemana,
    y          = ~Revenue,
    type       = "bar",
    marker     = list(color = COLORS$info),
    customdata = ~Transacciones,
    hovertemplate = "<b>%{x}</b><br>Revenue: £%{y:,.0f}<br>Transacciones: %{customdata}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis = list(title = "Día de la Semana"),
      yaxis = list(title = "Revenue Total (£)", tickformat = ",.0f")
    )
}

#' Top N productos por revenue
plot_top_productos <- function(clean, top_n = 10) {
  dat <- clean |>
    dplyr::group_by(Description) |>
    dplyr::summarise(
      Revenue  = sum(Revenue, na.rm = TRUE),
      Unidades = sum(Quantity, na.rm = TRUE),
      .groups  = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(Revenue)) |>
    dplyr::slice(1:top_n)

  plotly::plot_ly(
    dat,
    x           = ~Revenue,
    y           = ~reorder(Description, Revenue),
    type        = "bar",
    orientation = "h",
    marker      = list(color = COLORS$primary),
    customdata  = ~Unidades,
    hovertemplate = "<b>%{y}</b><br>Revenue: £%{x:,.0f}<br>Unidades vendidas: %{customdata}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis = list(title = "Revenue Total (£)", tickformat = ",.0f"),
      yaxis = list(title = "")
    )
}

#' Revenue por trimestre agrupado por año
plot_revenue_trimestral <- function(clean) {
  dat <- clean |>
    dplyr::group_by(Anio, Trimestre) |>
    dplyr::summarise(Revenue = sum(Revenue, na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(
      Periodo = paste0("Q", Trimestre),
      Anio    = as.character(Anio)
    )

  plotly::plot_ly(
    dat,
    x             = ~Periodo,
    y             = ~Revenue,
    color         = ~Anio,
    type          = "bar",
    hovertemplate = "<b>%{x}</b> %{fullData.name}<br>Revenue: £%{y:,.0f}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      barmode = "group",
      xaxis   = list(title = "Trimestre"),
      yaxis   = list(title = "Revenue (£)", tickformat = ",.0f"),
      legend  = list(title = list(text = "Año"))
    )
}

# =========== GRÁFICOS ADICIONALES DE EDA ===========

#' Heatmap de transacciones: hora del día × día de la semana
plot_heatmap_hora_dia <- function(clean) {
  dias_orden <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  dias_es    <- c("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")

  dat <- clean |>
    dplyr::mutate(
      DiaSemana = factor(DiaSemana, levels = dias_orden, labels = dias_es)
    ) |>
    dplyr::group_by(Hora, DiaSemana) |>
    dplyr::summarise(
      Transacciones = dplyr::n(),
      Revenue       = sum(Revenue, na.rm = TRUE),
      .groups = "drop"
    )

  plotly::plot_ly(
    dat,
    x             = ~DiaSemana,
    y             = ~Hora,
    z             = ~Transacciones,
    type          = "heatmap",
    colorscale    = list(c(0, "#EFF6FF"), c(1, COLORS$primary)),
    text          = ~paste0(Transacciones, " transacciones"),
    hovertemplate = "<b>%{x}</b> a las %{y}h<br>%{text}<br>Revenue: £%{customdata:,.0f}<extra></extra>",
    customdata    = ~Revenue
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis = list(title = "Día de la Semana"),
      yaxis = list(title = "Hora del Día", dtick = 2)
    )
}

#' Distribución de unidades por transacción
plot_dist_quantity <- function(clean) {
  limite <- quantile(clean$Quantity, 0.95, na.rm = TRUE)
  dat    <- clean |> dplyr::filter(Quantity <= limite)

  plotly::plot_ly(
    dat,
    x             = ~Quantity,
    type          = "histogram",
    nbinsx        = 50,
    marker        = list(color = COLORS$warning, opacity = 0.8),
    hovertemplate = "Cantidad: %{x}<br>Frecuencia: %{y}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis = list(title = "Unidades por Transacción"),
      yaxis = list(title = "Frecuencia")
    )
}

#' Revenue acumulado por segmento de precio a lo largo del tiempo
plot_revenue_segmento_tiempo <- function(clean) {
  dat <- clean |>
    dplyr::group_by(Fecha, Segmento_Precio) |>
    dplyr::summarise(Revenue = sum(Revenue, na.rm = TRUE), .groups = "drop") |>
    dplyr::arrange(Fecha)

  plotly::plot_ly(
    dat,
    x             = ~Fecha,
    y             = ~Revenue,
    color         = ~Segmento_Precio,
    type          = "scatter",
    mode          = "lines",
    hovertemplate = "<b>%{fullData.name}</b><br>%{x|%d/%m/%Y}<br>Revenue: £%{y:,.0f}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis  = list(title = "Fecha"),
      yaxis  = list(title = "Revenue (£)", tickformat = ",.0f"),
      legend = list(title = list(text = "Segmento"))
    )
}

# =========== GRÁFICOS ADICIONALES DE RFM ===========

#' Heatmap R_Score × F_Score coloreado por M_Score promedio
plot_rfm_scores_heatmap <- function(rfm_data) {
  dat <- rfm_data |>
    dplyr::group_by(R_Score, F_Score) |>
    dplyr::summarise(
      M_Promedio = mean(M_Score, na.rm = TRUE),
      N_Clientes = dplyr::n(),
      .groups = "drop"
    )

  plotly::plot_ly(
    dat,
    x             = ~F_Score,
    y             = ~R_Score,
    z             = ~M_Promedio,
    type          = "heatmap",
    colorscale    = "RdYlGn",
    text          = ~paste0(N_Clientes, " clientes"),
    hovertemplate = "R=%{y} | F=%{x}<br>M Score prom: %{z:.2f}<br>%{text}<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      xaxis = list(title = "F Score (Frecuencia)", dtick = 1),
      yaxis = list(title = "R Score (Recencia)", dtick = 1),
      coloraxis = list(colorbar = list(title = "M Score"))
    )
}

#' Proporción de clientes Activos vs En_Riesgo por segmento (barras apiladas %)
plot_activos_por_segmento <- function(rfm_data) {
  dat <- rfm_data |>
    dplyr::count(Segmento_Cliente, Es_Activo) |>
    dplyr::group_by(Segmento_Cliente) |>
    dplyr::mutate(Pct = round(n / sum(n) * 100, 1)) |>
    dplyr::ungroup()

  plotly::plot_ly(
    dat,
    x             = ~Segmento_Cliente,
    y             = ~Pct,
    color         = ~Es_Activo,
    type          = "bar",
    colors        = c(COLORS$danger, COLORS$success),
    customdata    = ~n,
    hovertemplate = "<b>%{x}</b><br>%{fullData.name}: %{y}% (%{customdata} clientes)<extra></extra>"
  ) |>
    tema_corporativo() |>
    plotly::layout(
      barmode = "stack",
      xaxis   = list(title = "Segmento"),
      yaxis   = list(title = "% Clientes", ticksuffix = "%", range = c(0, 100)),
      legend  = list(title = list(text = "Estado"))
    )
}