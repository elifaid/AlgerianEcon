#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
# Define server logic required to draw a histogram
function(input, output, session) {
  data<-reactive({
    Algeria
  })

    output$Indices <- renderPlotly({
      data()  %>% filter(GROUPES %in% input$groups) %>% ggplot(aes(y=value,x=date,color=GROUPES))+
        geom_line()+theme_bw()+ggtitle("Index Values",subtitle = "Source: Bank of Algeria")+xlab("Index Value")+
        scale_x_date(breaks = "5 years", date_labels  = "%Y")
    })
    output$Inflation_YOY<-renderPlotly({
      data() %>% filter(GROUPES %in% input$groups) %>% ggplot(aes(y=YoY,x=date,color=GROUPES))+
        geom_line()+theme_bw()+
        ylab(" % change")+
        scale_x_date(breaks = "5 years", date_labels  = "%Y")+
        scale_y_continuous(labels = scales::percent_format())+
        ggtitle("Year over Year Inflation (n.s.a)",subtitle = "Source: Bank of Algeria")
    })
    output$Distribution_MOM<-renderPlotly({
      data() %>% filter(GROUPES %in% input$groups) %>% 
        ggplot(aes(MoM,fill=GROUPES))+
        geom_histogram()+theme_bw()+
        scale_x_continuous(labels = scales::percent_format())+
        ggtitle("Distribution of Monthly Inflation",subtitle = "Source: Bank of Algeria")
    })

}
