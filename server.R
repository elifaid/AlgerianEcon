library(shiny)
library(shinydashboard)
function(input, output, session) {
  
  data<-reactive({
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
    Algeria
  })
  dataGDP<-reactive({
    Algeria3<- read_excel("PIB-T1_2000-T1_2023.xlsx")%>% pivot_longer(!GROUPE,names_to = "date") %>% arrange(as.numeric(date))
    Algeria3$date<-(seq(as.Date("2000/1/1"), as.Date("2023/1/1"), by = "quarter") %>% rep(each=10))
    Algeria3
  })
  output$GDP<-renderPlotly({
    dataGDP() %>% ggplot(aes(x=date,y=value/100,color=GROUPE))+geom_line()+
      theme_bw()+
      ylab("Quartley Growth (% annualized)")+
      xlab("Year")+
      scale_x_date(breaks = "5 years", date_labels  = "%Y")+
      scale_y_continuous(labels = scales::percent_format())+ggtitle("GDP growth")
  })
  output$Indices <- renderPlotly({
      data()  %>% filter(GROUPES %in% input$groups) %>% 
      ggplot(aes(y=value,x=date,color=GROUPES))+
        geom_line()+
        theme_bw()+
        ggtitle("Index Values",subtitle = "Source: Bank of Algeria")+
        xlab("Year")+
        ylab("Value")+
        scale_x_date(breaks = "5 years", date_labels  = "%Y")
    })
  
  output$Reserves<-renderPlotly({
    read_excel("Reserves-officielles-de-change-122015-092022.xlsx") %>% 
      ggplot(aes(x=Date,y=`Réserves officielles de change y compris DTS ( Or  monétaire non inclus)`))+
      theme_bw()+
      geom_line()+
      xlab("Year")+
      ggtitle("Foreign Exchange Reserves (Excluding Gold)")+
      ylab("Million USD")
  })
  
  
  BS<-reactive({
      read_excel("Situation-de-la-BA-011992-112022.xlsx") %>% 
      pivot_longer(-c(Group,Type),names_to="date") %>% 
      mutate(date=as.Date(as.numeric(date), origin = "1899-12-30"))
  })
  output$BS_Choice <- renderUI({
    selectInput(
      multiple=TRUE,
      "BS_Choice", 
      "Category Name",
      selected = "TOTAL ASSETS/LIABILITIES\n",
      unique(BS()$Type))
  })
    
  output$BalanceSheet<-renderPlotly({
    BS() %>% 
      filter(Type %in% input$BS_Choice) %>% 
      ggplot(aes(x=date,y=value,color=Type))+
      geom_line()+
      theme_bw()+
      ylab("Billion DZD")+
      scale_y_log10(labels = scales::label_dollar(prefix = "DZD ",scale=1/1000000000))+
      xlab("Year")
  })
  
  output$Inflation_YOY<-renderPlotly({
      data() %>% filter(GROUPES %in% input$groups) %>% 
      ggplot(aes(y=YoY,x=date,color=GROUPES))+
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
