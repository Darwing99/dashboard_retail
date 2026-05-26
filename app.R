# =============================================================================
# APP.R - PUNTO DE ENTRADA DE LA APLICACIÓN
# =============================================================================

# Cargar configuración global (librerías, datos, precomputaciones)
source("global.R", local = FALSE)

# Cargar módulos (garantiza disponibilidad antes de evaluar ui.R)
source("modules/mod_inicio.R",     local = FALSE)
source("modules/mod_negocio.R",    local = FALSE)
source("modules/mod_eda.R",        local = FALSE)
source("modules/mod_wrangling.R",  local = FALSE)
source("modules/mod_modelo.R",     local = FALSE)
source("modules/mod_evaluacion.R", local = FALSE)
source("modules/mod_rfm.R",        local = FALSE)
source("modules/mod_datos.R",      local = FALSE)

# Cargar UI y Server
source("ui.R", local = FALSE)
source("server.R", local = FALSE)

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)
