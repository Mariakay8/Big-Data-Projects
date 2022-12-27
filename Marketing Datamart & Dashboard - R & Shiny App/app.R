
###############################################################################
# BWIN SPORTS BETTING DASHBOARD 
###############################################################################

# Link to the app
# https://mkarakoulian.shinyapps.io/BWIN_Dashboard/?_ga=2.260091983.359045978.1671741479-752874449.1671741479

#=======================================================================
# LIBRARIES
#==============================================================================

if(!require("shiny")) install.packages("shiny"); library("shiny")
if(!require("shinydashboard")) install.packages("shinydashboard"); library("shinydashboard")
if(!require("ggplot2")) install.packages("ggplot2"); library("ggplot2")
if(!require("dplyr")) install.packages("dplyr"); library("dplyr")
if(!require("lubridate")) install.packages("lubridate"); library("lubridate")
if(!require("scales")) install.packages("scales"); library("scales")
if(!require("tidyverse")) install.packages("tidyverse"); library("tidyverse")
if(!require("maps")) install.packages("maps"); library("maps")

#==============================================================================
# DATA IMPORT
#==============================================================================

load("Datamart - Final.RData")

#==============================================================================
# BODY
#==============================================================================

ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "BWIN Dashboard"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Snapshot", tabName = "Summary", icon = icon("fa-sharp fa-solid fa-camera-retro")),
                        menuItem("Geographical View", tabName = "Overview", icon = icon("fa-sharp fa-solid fa-earth-americas")),
                        menuItem("User Segmentation", tabName = "Users", icon = icon("fa-sharp fa-solid fa-users-viewfinder")),
                        menuItem('Betting Activity',tabName='Bets', icon = icon("fa-sharp fa-solid fa-chart-line")),
                        menuItem('Poker Chip Conversions', tabName='Poker', icon = icon("fa-sharp fa-solid fa-heart")))),
                    dashboardBody(
                      tabItems(
                        tabItem(tabName = "Summary",
                                fluidRow(
                                  tags$div(align="left", valueBoxOutput("UsersBox")),
                                  tags$div(align="left", valueBoxOutput("StakesBox")),
                                  tags$div(align="left", valueBoxOutput("ProfitsBox")),
                                  box(plotOutput("UsersPlot"), title = "Registered Users (February 2005)", width=4, height=400),
                                  box(plotOutput("StakesPlot"), title = "Stakes (February - September 2005)", width=4, height=400),
                                  box(plotOutput("ProfitsPlot"), title = "Profits Made (February - September 2005)", width=4, height=400),
                                  tags$div(align="center", box(tableOutput("Top5Country1"), title = textOutput("Title3") , width=3, height=250, style = "font-size:110%", collapsible = FALSE, status = "primary",  collapsed = TRUE, solidHeader = TRUE)),
                                  tags$div(align="center", box(tableOutput("Top5Product1"), title = textOutput("Title4") , width=3, height=250, style = "font-size:110%", collapsible = FALSE, status = "primary",  collapsed = TRUE, solidHeader = TRUE)),
                                  tags$div(align="center", box(tableOutput("Top5Country"), title = textOutput("Title1") , width=3, height=250, style = "font-size:110%", collapsible = FALSE, status = "primary",  collapsed = TRUE, solidHeader = TRUE)),
                                  tags$div(align="center", box(tableOutput("Top5Product"), title = textOutput("Title2") , width=3, height=250, style = "font-size:110%", collapsible = FALSE, status = "primary",  collapsed = TRUE, solidHeader = TRUE)))),
                        tabItem(tabName = "Overview",
                                fluidRow(
                                  box(plotOutput("CountryPlot"), title = "Geographical Distribution of Users", width=12, height = 800))),
                        tabItem(tabName = "Users",
                                fluidRow(
                                  box(plotOutput("ApplicationPlot"), title = "Users by Website"),
                                  box(plotOutput("LanguagePlot"), title = "Users by Language"),
                                  box(plotOutput("GenderPlot"), title = "Users by Gender"),
                                  box(plotOutput("LoyaltyPlot"), title = "Users by Loyalty"),
                                  box(plotOutput("DiversityPlot"), title = "Users by Diversity"),
                                  box(plotOutput("RFMPlot"), title = "Users by RFM Score"))),
                        tabItem(tabName = "Bets",
                                fluidRow(
                                  tabBox(type = "tabs", width=12, height=530,
                                         tabPanel("Stakes", box(plotOutput("StakesProductPlot"), title="Stakes by Game"), box(plotOutput("StakesWeekdayPlot"), title="Stakes by Weekday")),
                                         tabPanel("Winnings", box(plotOutput("WinningsProductPlot"), title="Winnings by Game"), box(plotOutput("WinningsWeekdayPlot"), title="Winnings by Weekday")),
                                         tabPanel("Bets", box(plotOutput("BetsProductPlot"), title="Bets by Game"),  box(plotOutput("BetsWeekdayPlot"), title="Bets by Weekday")),
                                         tabPanel("Profits", box(plotOutput("ProfitsProductPlot"), title="Profits for BWIN by Game"),  box(plotOutput("ProfitsRFMPlot"), title="Distribution of Profits by Type of Customer"))))),
                        tabItem(tabName = "Poker",
                                fluidRow(
                                  sidebarLayout(
                                    sidebarPanel(width=2,
                                      radioButtons("Type", "Chose Transaction Type", c("Buy" = "Buy", "Sell" = "Sell")),
                                      selectInput("Indicator2", "Chose a Metric", choices=c("Number", "Amount"))),
                                    mainPanel(
                                      box(plotOutput("PokerPlot"), title = "Average Poker Transactions by Weekday", width = 6))))))))



# Define server logic
server <- function(input, output) {
  
  Users <- Datamart %>% summarize(nUsers = n())
  
  output$UsersBox <- renderValueBox({valueBox(prettyNum(Users, big.mark = ","), tags$p("Users", style = "font-size: 150%;"), input$UsersBox, icon=icon("fa-sharp fa-solid fa-users"), color = "blue")})
  
  Stakes <- Datamart %>% summarize(Stakes = sum(Total_Stakes))
  
  output$StakesBox <- renderValueBox({valueBox(paste0("€",prettyNum(Stakes, big.mark = ",")), tags$p("Stakes", style = "font-size: 150%;"), input$StakesBox, icon=icon("fa-sharp fa-solid fa-money-bill-transfer"), color = "aqua")})
  
  Profits <- Datamart %>% summarize(Profits = sum(Profit_bwin))
  
  output$ProfitsBox <- renderValueBox({valueBox(paste0("€", prettyNum(Profits, big.mark = ",")), tags$p("Profits", style = "font-size: 150%;"), input$ProfitsBox, icon=icon("fa-sharp fa-solid fa-sack-dollar"), color = "purple")})
  
  UsersData <- reactive({
    
    LineUsersData <- Datamart %>% mutate(RegDate = day(RegDate)) %>% group_by(RegDate) %>% summarize(nUserDay=n())
    LineUsersData})
  
  output$UsersPlot <- renderPlot({ggplot(UsersData(), aes(x=RegDate, y=nUserDay)) + 
      geom_line(color='deepskyblue', stat='identity', size=1) +
      geom_point(color='deepskyblue', size=3, aes(text = paste("Users:", nUserDay))) +
      theme_void() +
      scale_x_continuous(breaks=seq(1,30,by=2)) +
      scale_y_continuous(labels = comma) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}, height = 340)
  
  StakesData <- reactive({
    LineStakesData <- Aggregations %>% mutate(Month = month(Date)) %>% group_by(Month) %>% summarize(Stakes = sum(Stakes) / 1000000)
    LineStakesData})
  
  output$StakesPlot <- renderPlot({ggplot(StakesData(), aes(x=Month, y=Stakes)) + 
      geom_line(color='deepskyblue', stat='identity', size=1) +
      geom_point(color='deepskyblue', size=3) +
      theme_void() +
      scale_x_discrete(limits=c("Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep")) +
      scale_y_continuous(labels = dollar_format(prefix="€",suffix =" Mn")) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}, height = 340)
  
  ProfitsData <- reactive({
    LineStakesData <- Aggregations %>% mutate(Month = month(Date)) %>% group_by(Month) %>% summarize(Profits = (sum(Stakes) - sum(Winnings)) / 1000000)
    LineStakesData})
  
  output$ProfitsPlot <- renderPlot({ggplot(ProfitsData(), aes(x=Month, y=Profits)) + 
      geom_line(color='deepskyblue', stat='identity', size=1) +
      geom_point(color='deepskyblue', size=3) +
      theme_void() +
      scale_x_discrete(limits=c("Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep")) +
      scale_y_continuous(labels = dollar_format(prefix="€",suffix =" Mn")) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}, height = 340)
  
  Top5CountryData1 <- reactive({
    
    TableCountryData1 <- Datamart %>% group_by(Country_Name) %>% 
      summarise(n=n()) %>%
      arrange (desc(n)) %>%
      mutate(n=round(n/1000, 2)) %>%
      rename (Country= Country_Name, "Users (K)" = n) %>%
      head(3)
    TableCountryData1
  })
  
  output$Top5Country1 <- renderTable(Top5CountryData1(), spacing ="l")
  
  output$Title3 <- renderText(paste("Top 3 Countries by Users"))
  
  Top5ProductData1 <- reactive({
    
    TableProductData1 <- Aggregations %>% group_by(Product_Description) %>% 
      summarize(n = n() / 1000000) %>% 
      arrange (desc(n)) %>%
      rename (Game= Product_Description, "Users (Mn)" = n) %>%
      head(3)
    TableProductData1
  })
  
  output$Top5Product1 <- renderTable(Top5ProductData1(), spacing ="l")
  
  output$Title4 <- renderText(paste("Top 3 Games by Users"))
  
  
  Top5CountryData <- reactive({
    
    TableCountryData <- Datamart%>% select(Country_Name, Profit_bwin)%>%
      group_by(Country_Name)%>% 
      arrange (desc(Profit_bwin)) %>%
      mutate(Profit_bwin=round(Profit_bwin/1000, 2)) %>%
      rename (Country= Country_Name, "Profit (€K)" = Profit_bwin) %>%
      head(3)
    TableCountryData
  })
  
  output$Top5Country <- renderTable(Top5CountryData(), spacing ="l")
  
  output$Title1 <- renderText(paste("Top 3 Countries by Profits"))
  
  Top5ProductData <- reactive({
    
    TableProductData <- Aggregations %>% group_by(Product_Description) %>% 
      summarize(Profits = (sum(Stakes) - sum(Winnings)) / 1000000) %>% 
      arrange (desc(Profits)) %>%
      rename (Game= Product_Description, "Profit (€Mn)" = Profits) %>%
      head(3)
    
    TableProductData
  })
  
  output$Top5Product <- renderTable(Top5ProductData(), spacing ="l")
  
  output$Title2 <- renderText(paste("Top 3 Games by Profits"))
    
  CountryData <- reactive({
    
    World <- map_data("world")
    
    MapData <- Datamart %>% group_by(Country_Name) %>% summarize(nUserCountry=n())
    MapData <- merge(MapData, Geometry, by.x="Country_Name", by.y="name", all.x=TRUE, all.y=FALSE)
    MapData})
  
  mybreaks <- c(1, 100, 1000, 10000, 20000)

  output$CountryPlot <- renderPlot({ggplot() +
      geom_polygon(data = World, aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
      xlim(NA, 200) +
      ylim(-50,90) +
      geom_point(data=MapData, aes(x=longitude, y=latitude, size=nUserCountry, color=nUserCountry), stroke=F, alpha=0.7) +
      scale_size_continuous(name="Number of Users", trans="sqrt", range=c(1,20),breaks=mybreaks, labels = c("1-99", "100-999", "1,000-9,999", "10,000-19,999", "20,000+")) +
      scale_alpha_continuous(name="Number of Users", trans="sqrt", range=c(0.1, 0.9),breaks=mybreaks) +
      scale_color_viridis_c(option="inferno",name="Number of Users", trans="log", breaks=mybreaks, labels = c("1-99", "100-999", "1,000-9,999", "10,000-19,999", "20,000+")) +
      theme_void() + 
      guides( colour = guide_legend()) +
      theme(
        legend.position = "bottom",
        text = element_text(color = "#22211d", size=15),
        plot.background = element_rect(fill = "#ffffff", color = NA), 
        panel.background = element_rect(fill = "#ffffff", color = NA), 
        legend.background = element_rect(fill = "#ffffff", color = NA)
      )}, height = 750)
    
    
  
  ApplicationData <- reactive({
    
    ColumnApplicationData <- Datamart %>% group_by(Application_Description) %>% summarize(nUserApplication=n()) %>% mutate(Application_Description = fct_reorder(Application_Description, nUserApplication))
    ColumnApplicationData})
  
  output$ApplicationPlot <- renderPlot({ggplot(ApplicationData(), aes(x=nUserApplication, y=Application_Description)) + 
      geom_bar(fill='deepskyblue', stat='identity') +
      geom_text(aes(label = format(nUserApplication, big.mark = ",")), hjust=-0.2, colour = "black", size = 5) +
      xlim(NA, 25000) +                                       
      theme_void() +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  
  
  LanguageData <- reactive({
    
    ColumnData <- Datamart %>% group_by(Language_Description) %>% summarize(nUserLanguage=n()) %>% mutate(Language_Description = fct_reorder(Language_Description, nUserLanguage))
    ColumnData
  })
  
  
  output$LanguagePlot <- renderPlot({ggplot(LanguageData(), aes(x=nUserLanguage, y=Language_Description)) + 
      geom_bar(fill='deepskyblue', stat='identity') +
      geom_text(aes(label = format(nUserLanguage, big.mark = ",")), hjust=-0.2, colour = "black", size = 5) +
      xlim(NA, 30000) +                                       
      theme_void() +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  
  GenderData <- reactive({
    PieGenderData <- Datamart %>% group_by(Gender_Description) %>% summarize(nUserGender=n()) %>% mutate(Gender_Description = fct_reorder(Gender_Description, nUserGender), PercentGender = nUserGender / sum(nUserGender))
    PieGenderData 
  })
  
  
  output$GenderPlot <- renderPlot({ ggplot(GenderData(), aes(x="", y = PercentGender, fill=Gender_Description)) + 
      geom_bar(stat = "identity") +
      coord_polar(theta = "y", start = 0) +
      theme_void() +
      labs(fill = "") +                              
      scale_fill_manual(values=c("lightgrey", "deepskyblue")) +
      geom_text(aes(label = paste0(round(PercentGender*100), "%" )), position = position_stack(vjust = 0.5), size=5) +
      theme(legend.title = element_text(size = 18), legend.text = element_text(size = 14))})
  
  LoyaltyData <- reactive({
    PieLoyaltyData <- Datamart %>% filter(!is.na(Loyalty)) %>% group_by(Loyalty) %>% summarize(nUserLoyalty=n()) %>% mutate(Loyalty = fct_reorder(Loyalty, nUserLoyalty), PercentLoyalty = nUserLoyalty / sum(nUserLoyalty))
    PieLoyaltyData 
  })
  
  output$LoyaltyPlot <- renderPlot({ ggplot(LoyaltyData(), aes(x="", y = PercentLoyalty, fill=Loyalty)) + 
      geom_bar(stat = "identity") +
      coord_polar(theta = "y", start = 0) +
      theme_void() +
      labs(fill = "") +
      scale_fill_manual(values=c("lightgrey", "deepskyblue")) +
      geom_text(aes(label = paste0(round(PercentLoyalty*100), "%" )), position = position_stack(vjust = 0.5), size=5) +
      theme(legend.title = element_text(size = 18), legend.text = element_text(size = 14))})
  
  DiversityData <- reactive({
    PieDiversityData <- Datamart %>% group_by(Diversified) %>% summarize(nUserDiversified=n()) %>% mutate(Diversified = ifelse(Diversified == 1, 'Play Multiple Games', 'Play Only 1 Game'), PercentDiversified = nUserDiversified / sum(nUserDiversified))
    PieDiversityData 
  })
  
  output$DiversityPlot <- renderPlot({ggplot(DiversityData(), aes(x="", y = PercentDiversified, fill=Diversified)) + 
      geom_bar(stat = "identity") +
      coord_polar(theta = "y", start = 0) +
      theme_void() +
      labs(fill = "") +
      scale_fill_manual(values=c("deepskyblue", "lightgrey")) +
      geom_text(aes(label = paste0(round(PercentDiversified*100), "%" )), position = position_stack(vjust = 0.5), size=5) +
      theme(legend.title = element_text(size = 18), legend.text = element_text(size = 14))
  })
  
  
  
  RFMData <- reactive({
    PieRFMData <- Datamart %>% filter(!is.na(RFM_Score)) %>% mutate(Customer_Type = ifelse(RFM_Score <= mean(RFM_Score, na.rm=T),'Low', ifelse(RFM_Score <= 300 ,'Mid',"High"))) %>%
      group_by(Customer_Type) %>%
      summarize(percentage=n()/nrow(Datamart))
    PieRFMData 
  })
  
  output$RFMPlot <- renderPlot({ggplot(RFMData(), aes(x="", y = percentage, fill=Customer_Type)) + 
      geom_bar(stat = "identity") +
      coord_polar(theta = "y", start = 0) +
      theme_void() +
      labs(fill = "") +
      scale_fill_manual(labels=c("High", "Mid", "Low"), values=c("deepskyblue", "grey", "lightgrey")) +
      geom_text(aes(label = paste0(round(percentage*100), "%" )), position = position_stack(vjust = 0.5), size=5) +
      theme(legend.title = element_text(size = 18), legend.text = element_text(size = 14))
  })
  
  IndicatorProductData <- reactive({
    BarProductData <- Aggregations %>% group_by(Product_Description)  %>% summarize(Stakes=sum(Stakes), Winnings=sum(Winnings), Bets=sum(Bets), Profits = (sum(Stakes) - sum(Winnings)), Returns = (sum(Winnings) - sum(Stakes)))
    BarProductData
  })
  
  ProfitsCustomerData <- reactive({  
    PieProfitsData <- Datamart %>% filter(!is.na(RFM_Score)) %>% mutate(Customer_Type = ifelse(RFM_Score <= mean(RFM_Score, na.rm=T),'Low', ifelse(RFM_Score <= 300 ,'Mid',"High"))) %>%
                        group_by(Customer_Type) %>%
                        summarize(ProfitsCustomer=sum(Profit_bwin))
    PieProfitsData
  })
  
  output$StakesProductPlot <- renderPlot({ggplot(IndicatorProductData(), aes(x=Stakes, y=reorder(Product_Description, Stakes))) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0("€", round(Stakes/1000000), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      theme_void() +
      xlim(NA, 40000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  output$WinningsProductPlot <- renderPlot({ggplot(IndicatorProductData(), aes(x=Winnings, y=reorder(Product_Description, Winnings))) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0("€", round(Winnings/1000000), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      theme_void() +
      xlim(0, 40000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  output$BetsProductPlot <- renderPlot({ggplot(IndicatorProductData(), aes(x=Bets, y=reorder(Product_Description, Bets))) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0(round(Bets/1000000,2), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      theme_void() +
      xlim(0, 8000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  output$ProfitsProductPlot <- renderPlot({ggplot(IndicatorProductData(), aes(x=Profits, y=reorder(Product_Description, Profits))) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0("€", round(Profits/1000000,2), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      theme_void() +
      xlim(NA, 5000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  output$ProfitsRFMPlot <- renderPlot({ggplot(ProfitsCustomerData(), aes(x="", y = ProfitsCustomer, fill=Customer_Type)) + 
      geom_bar(stat = "identity") +
      coord_polar(theta = "y", start = 0) +
      theme_void() +
      labs(fill = "") +
      scale_fill_manual(labels=c("High", "Mid", "Low"), values=c("deepskyblue", "grey", "lightgrey")) +
      geom_text(aes(label = paste0("€", round(ProfitsCustomer/1000000,2), " Mn" )), position = position_stack(vjust = 0.5), size=5) +
      theme(legend.title = element_text(size = 18), legend.text = element_text(size = 14))
    })
    
  
  IndicatorWeekdayData <- reactive({
    BarWeekdayData <- Aggregations %>% group_by(Weekday)  %>% summarize(Stakes=sum(Stakes), Winnings=sum(Winnings), Bets=sum(Bets))  
    BarWeekdayData
  })
  
  output$StakesWeekdayPlot <- renderPlot({ggplot(IndicatorWeekdayData(), aes(x=Stakes, y=Weekday)) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0("€", round(Stakes/1000000), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      scale_y_discrete(limits=c("Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday", "Sunday")) +
      theme_void() +
      xlim(NA, 25000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))})
  output$WinningsWeekdayPlot <- renderPlot({ggplot(IndicatorWeekdayData(), aes(x=Winnings, y=Weekday)) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0("€", round(Winnings/1000000), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      scale_y_discrete(limits=c("Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday", "Sunday")) +
      theme_void() +
      xlim(NA, 25000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}) 
  output$BetsWeekdayPlot <- renderPlot({ggplot(IndicatorWeekdayData(), aes(x=Bets, y=Weekday)) + 
      geom_bar(fill='deepskyblue', stat = "identity") +
      geom_text(aes(label = paste0(round(Bets/1000000,2), " Mn")), hjust=-0.2, colour = "black", size = 5, check_overlap = TRUE) +
      scale_y_discrete(limits=c("Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday", "Sunday")) +
      theme_void() +
      xlim(NA, 3000000) +
      theme(axis.text.y = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}) 
  
  
  # S
  IndicatorPockerData <- reactive({
    pokerbuyproduct<-Datamart%>% 
      select(UserID,AVG_TransAmount_Buy_Tuesday,AVG_TransAmount_Buy_Sunday,
             AVG_TransAmount_Buy_Monday,AVG_TransAmount_Buy_Thursday,
             AVG_TransAmount_Buy_Wednesday,AVG_TransAmount_Buy_Friday,
             AVG_TransAmount_Buy_Saturday)%>%
      pivot_longer(cols=-UserID,
                   names_to="weekday", values_to=c("avg_buy_trans"))%>%
      mutate(weekday=recode(weekday,
                            AVG_TransAmount_Buy_Tuesday="Tue",
                            AVG_TransAmount_Buy_Sunday ="Sun",
                            AVG_TransAmount_Buy_Wednesday ="Wed",
                            AVG_TransAmount_Buy_Friday="Fri",
                            AVG_TransAmount_Buy_Monday="Mon",
                            AVG_TransAmount_Buy_Thursday="Thu",
                            AVG_TransAmount_Buy_Saturday ="Sat" ))
    
    pokerbuyproductgrp<-pokerbuyproduct%>%group_by(weekday)%>%
      summarise(avg_buy_trans=mean(avg_buy_trans))
    
    #poker visualization average transaction amount-weekday-sell
    pokersellproduct<-Datamart%>% 
      select(UserID,AVG_TransAmount_Sell_Tuesday,AVG_TransAmount_Sell_Sunday,
             AVG_TransAmount_Sell_Monday,AVG_TransAmount_Sell_Thursday,
             AVG_TransAmount_Sell_Wednesday,AVG_TransAmount_Sell_Friday,
             AVG_TransAmount_Sell_Saturday)%>%
      pivot_longer(cols=-UserID,
                   names_to="weekday", values_to=c("avg_sell_trans"))%>%
      mutate(weekday=recode(weekday,
                            AVG_TransAmount_Sell_Tuesday="Tue",
                            AVG_TransAmount_Sell_Sunday ="Sun",
                            AVG_TransAmount_Sell_Wednesday ="Wed",
                            AVG_TransAmount_Sell_Friday="Fri",
                            AVG_TransAmount_Sell_Monday="Mon",
                            AVG_TransAmount_Sell_Thursday="Thu",
                            AVG_TransAmount_Sell_Saturday ="Sat" ))
    
    pokersellproductgrp<-pokersellproduct%>%group_by(weekday)%>%
      summarise(avg_sell_trans=mean(avg_sell_trans))
    
    
    pokerProductData <- merge(pokerbuyproductgrp, pokersellproductgrp, by="weekday", all.x=TRUE, all.y=TRUE) 
    pokerProductData
    
  }) 
  #number of trans 
  
  number_of_trans <- reactive({
    pokerbuy<-Datamart%>% 
      select(UserID,Nbr_Trans_Buy_Tuesday,Nbr_Trans_Buy_Sunday,Nbr_Trans_Buy_Friday,Nbr_Trans_Buy_Monday,Nbr_Trans_Buy_Saturday,Nbr_Trans_Buy_Thursday,Nbr_Trans_Buy_Wednesday)%>%
      pivot_longer(cols=-UserID,names_to="weekday", values_to=c("nbr_trans"))%>%
      mutate(weekday=recode(weekday,
                            Nbr_Trans_Buy_Tuesday="Tue",
                            Nbr_Trans_Buy_Sunday ="Sun",
                            Nbr_Trans_Buy_Wednesday ="Wed",
                            Nbr_Trans_Buy_Friday="Fri",
                            Nbr_Trans_Buy_Monday="Mon",
                            Nbr_Trans_Buy_Thursday="Thu",
                            Nbr_Trans_Buy_Tuesday ="Tue",
                            Nbr_Trans_Buy_Saturday ="Sat" ))
    
    poker_grp_buy<-pokerbuy%>%group_by(weekday)%>%
      summarise(total_trans_buy=sum(nbr_trans),
                avg_trans_buy=mean(nbr_trans))
    
    pokersell<-Datamart%>% 
      select(UserID,Nbr_Trans_Sell_Tuesday,Nbr_Trans_Sell_Sunday,Nbr_Trans_Sell_Friday,Nbr_Trans_Sell_Monday,Nbr_Trans_Sell_Saturday,Nbr_Trans_Sell_Thursday,Nbr_Trans_Sell_Wednesday)%>%
      pivot_longer(cols=-UserID,names_to="weekday", values_to=c("nbr_trans"))%>%
      mutate(weekday=recode(weekday,
                            Nbr_Trans_Sell_Tuesday="Tue",
                            Nbr_Trans_Sell_Sunday ="Sun",
                            Nbr_Trans_Sell_Wednesday ="Wed",
                            Nbr_Trans_Sell_Friday="Fri",
                            Nbr_Trans_Sell_Monday="Mon",
                            Nbr_Trans_Sell_Thursday="Thu",
                            Nbr_Trans_Sell_Tuesday ="Tue",
                            Nbr_Trans_Sell_Saturday ="Sat" ))
    
    poker_grp_sell<-pokersell%>%group_by(weekday)%>%
      summarise(total_trans_sell=sum(nbr_trans),
                avg_trans_sell=mean(nbr_trans))
    
    
    total_avg <- merge(poker_grp_buy, poker_grp_sell, by="weekday", all.x=TRUE, all.y=TRUE) 
    total_avg
  })
  
  
  #poker visualization average transaction amount weekday - plots
  
  output$PokerPlot <- renderPlot({
    if(input$Type =="Buy"& input$Indicator2=="Amount"){ggplot(IndicatorPockerData(), aes(x=weekday, y=avg_buy_trans, group=1)) + 
        geom_bar(fill="deepskyblue", stat='identity') +
        theme_void() +
        scale_x_discrete(limits=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")) +
        scale_y_continuous(labels = dollar_format(prefix="€", suffix ="")) +
        theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}
    else if(input$Type =="Buy"& input$Indicator2=="Number"){ggplot(number_of_trans(), aes(x=weekday, y=avg_trans_buy, group=1)) + 
        geom_bar(fill="deepskyblue", stat='identity') +
        theme_void() +
        scale_x_discrete(limits=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")) +
        theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}
    else if(input$Type =="Sell"& input$Indicator2=="Amount"){ggplot(IndicatorPockerData(), aes(x=weekday, y=avg_sell_trans, group=1)) + 
        geom_bar(fill="deepskyblue", stat='identity') +
        theme_void() +
        scale_x_discrete(limits=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")) +
        scale_y_continuous(labels = dollar_format(prefix="€", suffix ="")) +
        theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}
    else if(input$Type =="Sell"& input$Indicator2=="Number"){ggplot(number_of_trans(), aes(x=weekday, y=avg_trans_sell, group=1)) + 
        geom_bar(fill="deepskyblue", stat='identity') +
        theme_void() +
        scale_x_discrete(limits=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")) +
        theme(axis.text.y = element_text(size = 14, hjust = 1), axis.text.x = element_text(size = 14, hjust = 1), plot.margin = margin(rep(15, 4)))}
  })
  
}

shinyApp(ui = ui, server = server)

