#Dependencies
require('rCharts')
require('shiny')
require("quantmod")
require("TTR")
require("stringr")
require('lubridate')
require('tseries')
require('googleVis')
require('PerformanceAnalytics')

#functions used to get or transform data

#Getting Eric Zivot's portfolio library
source(file="http://spark-public.s3.amazonaws.com/compfinance/R%20code/portfolio.r")

#Get stock data from Yahoo, setting the dates and the ticker

getstockdata <- function (ticker){ 
  prices = get.hist.quote(instrument=ticker,
          start="1998-01-01",end="2012-05-31",
          quote="AdjClose",provider="yahoo",
          origin="1970-01-01",compression="m",
          retclass="zoo")} 

#Function to calculate Continuosly Compounded Returns 

ccr <- function(x){ 
  round ((log(x[-1]) - log(x[-length(x)])),digits = 2)}



## server.r
shinyServer(function(input, output) {
  
  
  stocks <- reactiveValues(stocks = NA)
  
  observe({
    
    # If Submit buttom have been pressed
    
    if(input$submit > 0) {
      
      stocks$stocks <- isolate(input$stocks)
      stocks$number <- isolate(input$numstock)
            
      # Creation of empty data structures to manage data
      if (stocks$number == length(stocks$stocks)){
          text = ""
          dataframe = data.frame(1:173)
          vectornames = c()
        
          #For every stock selected, data is retrieved from Yahoo and stocked into a Data.Frame object.
          for (i in 1:stocks$number){
            
              #Get stock's tickers from input
              stockticker = substr(stocks$stocks[i],1,regexpr("-",stocks$stocks[i])[1]-1)
              vectornames = c(vectornames, stockticker)
              stockindex = getstockdata(stockticker)
              dataframe = data.frame(dataframe, value = as.vector(stockindex) )
          
          }#for
        
          #Transform zoo structures to data.frame to plot graphs.
          date = as.vector(as.character(time(stockindex)))
          dataframe = data.frame(dataframe, date)
          dataframe = dataframe[,-1]
          colnames(dataframe) = c(vectornames,"date")
        
            # First output. Stocks evolution using rCharts and Morris. Input= data.frame with stocks evolution.
            output$graph1 <- renderChart2({
                m1 = mPlot(x = "date", y = vectornames, type="Line", data = dataframe)
                m1$params$width = 1200
                m1$params$height = 325
                m1$set(pointSize = 0, lineWidth = 1 )
                m1$set(title="Stocks Evolution")
              
                return(m1)
            })#output
          
          # Getting Continuosly Compounded Returns from previous data frame.
          dataframercc = dataframe[1:stocks$number]
          dataframercc = apply(dataframercc,2,ccr)
          dataframercc = data.frame(dataframercc ,dataframe[1:nrow(dataframe)-1,stocks$number+1])
          colnames(dataframercc) = c(vectornames,"date")
          
            # CCR monthtly representation          
            output$graph2 <- renderChart2({
              
              m1 = mPlot(x = "date", y = vectornames, type="Line", data = dataframercc)
              m1$params$width = 1200
              m1$params$height = 325
              m1$set(pointSize = 0, lineWidth = 1 )
              m1$set(title="Stocks Evolution")
              
              return(m1)
            })#output
          output$text <- renderText({text})
          
      
          
      #----------------------     
      
      # Getting statictical stimates to compute efficient portfolios. 
      muhat.annual = apply(dataframercc[,1:stocks$number],2,mean)*12   
      sigma2.annual = apply(dataframercc[,1:stocks$number],2,var)*12
      sigma.annual = sqrt(sigma2.annual)
      covmat.annual = round(cov(dataframercc[,1:stocks$number])*12,digits=4) 
      
      # Risk free ratio (T-Bills) Used to compute Tangency portfolio.
      r.free = 0.005
      
      #Getting the Global Minimum Portfolio. The portfolio offering maximun Return with minimun Risk
      gmin.port = globalMin.portfolio(muhat.annual, covmat.annual)
      
      #Calculate the set of efficient portfolio. Efficient frontiers
      ef = efficient.frontier(muhat.annual, covmat.annual,alpha.min=-2, alpha.max=1.5, nport=20)
      
      #Calculate tangency portfolio, with R.free
      tan.port = tangency.portfolio(muhat.annual, covmat.annual,r.free)
      
      
      #Data processing (dataframe) to plot efficient portfolio with GoogleVis Bubble Chart
      newdataframe = data.frame(as.numeric(ef$sd),as.numeric(ef$er) )
      newdataframe = round (newdataframe,2)
      newdataframe = data.frame(1:nrow(newdataframe),"EfficientPortfolio",newdataframe,stringsAsFactors=FALSE)
      newdataframe = rbind(newdataframe,c(nrow(newdataframe)+1,"GlobalMinPortfolio",round(gmin.port$sd,2),round(gmin.port$er,2)))
      newdataframe = rbind(newdataframe,c(nrow(newdataframe)+2,"Tangency",round(tan.port$sd,2),round(tan.port$er,2)))
      
      for (i in 1:stocks$number){
        newdataframe = rbind(newdataframe,c(nrow(newdataframe)+2+i,vectornames[i],round(covmat.annual[i,i],2),round(muhat.annual[i],2)))
      }
      
      colnames(newdataframe) = c("Id","Type","SD","ER")  
      
      aux = c(rep("Eff.Port.",nrow(newdataframe)-stocks$number-2),"Glob.Min.Port.","Tangen.",vectornames)
      newdataframe = data.frame(aux,newdataframe[,2:4])
      
      
              #GoogleVis Bubble Chart representation of efficient portfolios + stock + global min portfolio + tangency portfolio
              output$graph3 <- renderGvis({gvisBubbleChart(newdataframe, xvar = "SD", yvar = "ER",
                                                           colorvar = "Type",
                                                           options=list(hAxis='{title: "Standard Deviation"}',
                                                                        vAxis='{title: "Expected Return"}',
                                                                        height=325,width=1200,
                                                                        title = "Efficient Frontier",
                                                                        bubble="{textStyle:{color: 'none'}}",
                                                                        sizeAxis ='{minValue: 0,  maxSize: 10}' 
                                                           ))
              })#output
          
      
      #Data management to display GoogleVis stacked chart portfolio
      framedata = data.frame(as.numeric(ef$sd),as.numeric(ef$er))
      framedata= data.frame(framedata,ef[4])
      framedata = round (framedata,2)
      
      vnames = c("SD","ER")
      
      for (i in 1:stocks$number){
        vnames = c(vnames,vectornames[i])
      } 
      
      colnames(framedata) = vnames 
      
      framedata = framedata[seq(1,nrow(framedata),2),]                      
      
      
      #GoogleVis stacked Column chart display
      output$graph4 <- renderGvis({gvisColumnChart(framedata, xvar="ER", yvar=vectornames,
                                                   options=list(title="Efficient Portfolios Composition by ER",
                                                                isStacked=TRUE,
                                                                height=325,width=1200,
                                                                titleTextStyle="{color:'black',fontSize:16}",
                                                                bar="{groupWidth:'75%'}"))                     
                                   
      })#output
      
      #Data management to prepara GoogleVis table and calculate VaR
      framedata = data.frame(framedata, rep(10000,nrow(framedata)))
      
      #VaR calculation q=5%
      framedata = data.frame(framedata, framedata[ncol(framedata)]*(framedata[2]+framedata[1]*(-1.645)))
      colnames(framedata) = c(vnames, "Initial Investment","VaR q=5%")  
      
      #GoogleVis Table display
      output$table1 <- renderGvis({gvisTable(framedata, options=list(page='enable', height=300, width=1200))                     
                                   
      })#output
      
      
      #-----------------------    
     }#if
      
      #In case number of stock and stocks don't match
      else{
          text = "Sorry, your selection doesn't match the number previously selected. Try again, please"
          output$text <- renderText({text})
            
      }#else
    }#if
  })#observe
})#shinyserver