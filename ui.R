## ui.R
require('rCharts')
require('shiny')
require("quantmod")
require("TTR")
require("stringr")
require('lubridate')

str = c("AMZN-Amazon.con Inc","MSFT-Microsoft Corp.","NOC-Northrop Grumman Corp.","PEP-Pepsico", "RTN- Raytheon Co.","SBUX-Starbucks Corp.","TYC-Tyco International","UTX-United Technologies","WMT-Wal-Mart Stores","WFC-Well Fargo","XRX-Xerox Corp") 

#Initial introduction message

intro = "Given a set of SP500's Stock Values, the application calculates the efficient portfolios, the set
         of optimal portfolios that offers the highest expected return for a defined level of risk (SD), or the 
         lowest risk for a given level of return (ER). Portfolios liying below the efficient frontier are suboptimal,
         as they don't provide enought return for a given risk level." 
intro2=  "As short positions are allowed, some portfolios present negatives values for some Stocks."
intro3=  "This application doesn't:"  
intro4="              - Include T-Bills in portfolios composition."                      
intro5="              - Allow No Short-sales scenarios."
intro6="Move through the pannels ->"

#User guide text

user1= "Set a number of stocks and select the stocks corresponding to that number. Afterwards, press Submit. Navigate accross the set of pannels to recreate the different portfolios created with the selected stocks."

user3="Results interpretation"

user4= "Stocks Value: Graphical representation of the evolutions of stock's prices over the years. Data from: Yahoo Finance."
user5="Stocks Return: Monthly Continuously Compounded Return for the given stocks values."  
user6="Efficient Portfolios: Set of efficient portfolio representing the efficient frontier (in blue). Alltogether, the Global Minimum Variance Portfolio (Higher return with minimum variance), the Tangency Portfolio and the Returns and variances of stocks are represented."
user7="Portfolio Composition: Graphical representation of the composition of the Portfolios Vs. Expected Return. The negative values respond to short-positions"
user8="Compostion Table: Table showing Returns (ER), Variances (SD), Portfolio Composition and Value at Risk for a given q=0.05."

shinyUI(fluidPage(
  verticalLayout(
    #Main Title
    
    titlePanel("Efficient Portfolio Analysis"),
    
    
    #FluidRow to introduce input variables. Two fields (number of stock & stocks) and a submit button.
    fluidRow(
      column(3,offset = 0,sliderInput('numstock',label = h5("Select Number of Stocks"),min = 2, max= 6, value =3,step=1)),
        
      column(4, offset = 1,selectInput("stocks", label = h5("Select your Stocks:"),str, multiple = TRUE)),
        
      column(4,offset = 0, h5("Create Portfolio"),actionButton("submit","Submit"))
      
    ),
    hr(),
    
    #TabPanel with different display options
    
    tabsetPanel(
      tabPanel("Introduction", h4(intro),br(),h4(intro2),br(),h4(intro3),br(),h4(intro4,align = "center"),h4(intro5,align = "center"),br(),h6(intro6,align="right")),
      tabPanel("User's Guide",h4("User's Guide"),br(),h5(user1),br(),h4(user3),br(),h5(user4),h5(user5),h5(user6),h5(user7),h5(user8)),
      tabPanel("Stocks Value", showOutput('graph1',lib='morris'), textOutput("text")),
      tabPanel("Monthly Returns", showOutput('graph2',lib='morris')),
      tabPanel("Efficient Portfolios",htmlOutput('graph3')),
      tabPanel("Portfolio Composition",htmlOutput('graph4')),
      tabPanel("Composition Table", htmlOutput('table1'))
      )
    
  
)
))
