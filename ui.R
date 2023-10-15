#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(readxl)

IndexChoices=c("Alimentations - Boissons non alcoolisées",
"Habillement - Chaussures",
"Logements - Charges",
"Meubles et Articles d'Ameublement",
"Santé - Hygiène Corporelle",
"Transports et Communications",
"Education - Culture - Loisirs",
"Divers (N.D.A)",
"IPC GLOBAL")


# Define UI for application that draws a histogram

dashboardPage(
  dashboardHeader(title = "Algerian Economic Data",titleWidth = "300px"),
  dashboardSidebar(sidebarMenu(
    menuItem("Central Bank",tabName = "CentralBank",icon = icon("dashboard")),
    menuItem("Inflation",tabName = "inflation",icon = icon("dashboard")),
    menuItem("GDP",tabName = "gdp",icon = icon("dashboard")))
    
    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "CentralBank",
              uiOutput("BS_Choice"),
              plotlyOutput("BalanceSheet"),
              plotlyOutput("Reserves")),
      tabItem(tabName = "inflation",
        selectInput("groups",
                "Groups",
                choices=IndexChoices,
                multiple = TRUE,
                selected = "IPC GLOBAL"),
          plotlyOutput("Inflation_YOY"),
          plotlyOutput("Distribution_MOM"),
          plotlyOutput("Indices")
        ),
      tabItem(tabName = "gdp",
              plotlyOutput("GDP"))
      )
    )
)
