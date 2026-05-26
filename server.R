# =============================================================================
# SERVER.R - LÓGICA DEL SERVIDOR
# =============================================================================

server <- function(input, output, session) {

  mod_inicio_server("inicio")

  mod_negocio_server("negocio",
    retail_clean = retail_clean
  )

  mod_eda_server("eda",
    retail_clean = retail_clean
  )

  mod_wrangling_server("wrangling",
    retail_raw   = retail_raw,
    retail_clean = retail_clean
  )

  mod_modelo_server("modelo",
    modelo_rf   = modelo_rf,
    train_data  = train_data,
    test_data   = test_data,
    conf_matrix = conf_matrix
  )

  mod_evaluacion_server("evaluacion",
    roc_obj     = roc_obj,
    auc_val     = auc_val,
    conf_matrix = conf_matrix,
    acc_pct     = acc_pct
  )

  mod_rfm_server("rfm",
    rfm_data = rfm_data
  )

  mod_datos_server("datos",
    retail_clean = retail_clean
  )

}
