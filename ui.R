# =============================================================================
# UI.R - INTERFAZ DE USUARIO
# =============================================================================

ui <- shinydashboard::dashboardPage(
  skin = "blue",

  # =========== HEADER ===========
  shinydashboard::dashboardHeader(
    title = span(
      icon("shopping-cart"),
      " Análisis Retail Dashboard"
    ),
    titleWidth = 350
   
  ),

  # =========== SIDEBAR ===========
  shinydashboard::dashboardSidebar(
    width = 260,
    shinydashboard::sidebarMenu(
      shinydashboard::menuItem("Inicio",        tabName = "inicio",     icon = icon("home")),
      shinydashboard::menuItem("F1: Negocio",   tabName = "negocio",    icon = icon("briefcase")),
      shinydashboard::menuItem("F2: Datos (EDA)",tabName = "eda",        icon = icon("chart-bar")),
      shinydashboard::menuItem("F3: Wrangling", tabName = "wrangling",  icon = icon("wrench")),
      shinydashboard::menuItem("F4: Modelado",  tabName = "modelo",     icon = icon("brain")),
      shinydashboard::menuItem("F5: Evaluación",tabName = "evaluacion", icon = icon("chart-pie")),
      shinydashboard::menuItem("F6: RFM",       tabName = "rfm",        icon = icon("users")),
      shinydashboard::menuItem("F7: Datos Raw", tabName = "datos",      icon = icon("database"))
    )
  ),

  # =========== BODY ===========
  shinydashboard::dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),

    shinydashboard::tabItems(
      shinydashboard::tabItem(tabName = "inicio",     mod_inicio_ui("inicio")),
      shinydashboard::tabItem(tabName = "negocio",    mod_negocio_ui("negocio")),
      shinydashboard::tabItem(tabName = "eda",        mod_eda_ui("eda")),
      shinydashboard::tabItem(tabName = "wrangling",  mod_wrangling_ui("wrangling")),
      shinydashboard::tabItem(tabName = "modelo",     mod_modelo_ui("modelo")),
      shinydashboard::tabItem(tabName = "evaluacion", mod_evaluacion_ui("evaluacion")),
      shinydashboard::tabItem(tabName = "rfm",        mod_rfm_ui("rfm")),
      shinydashboard::tabItem(tabName = "datos",      mod_datos_ui("datos"))
    )
  )
)
