#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

Algeria<- read_excel("Indice-des-prix-a-la-consommation-base-1989-011990-122001.xlsx")
Algeria2<- read_excel("IPC-y-compris-hors-alimentation-base-2001-_012002-082023.xlsx")

Algeria<-Algeria %>% 
  pivot_longer(!GROUPES,names_to = "date")%>% 
  mutate(date=as.Date(as.numeric(date), origin = "1899-12-30"))

Algeria %>% filter(date==max(date)) %>% mutate(value2=value) %>% select(GROUPES,value2) ->indexing

Algeria2<-Algeria2 %>% 
  pivot_longer(!GROUPES,names_to = "date")%>% 
  mutate(date=as.Date(as.numeric(date), origin = "1899-12-30"))%>% left_join(indexing) %>% mutate(value=value*(value2/100))

Algeria<-bind_rows(Algeria,Algeria2)
Algeria<-Algeria  %>% 
  group_by(GROUPES) %>% 
  mutate(YoY=(value/lag(value,12))-1) %>% 
  mutate(MoM=value/lag(value,1)-1)

# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "Algerian Economic Data",titleWidth = "300px"),
  dashboardSidebar(),
  dashboardBody(
    selectInput("groups",
                "Groups",
                choices=unique(Algeria$GROUPES),
                multiple = TRUE,
                selected = "IPC GLOBAL"
                    
    ),
    plotlyOutput("Inflation_YOY"),
    plotlyOutput("Distribution_MOM"),
    plotlyOutput("Indices")
  )
)
