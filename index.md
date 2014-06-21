---
title       : Efficient Portfolios Application
subtitle    : Efficient Frontiers with no risk-free asset 
author      : Felix
job         : 
logo        : 
framework   : io2012       # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
url         :    
  lib: ../libraries
  assets: ../assets
  
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
---

## App Summary



1. Select a number of stocks to consider

2. Select the stocks 

3. Download Financial Data from Yahoo Finance. Monthly values from 1998.

4. Statistical analysis of time series 

5. Calculate Efficient Portfolios & Global Minimum Variance Portfolio and Tangency Portfolio 

6. Display Output Graphs and Calculate Value at Risk 

--- .class #id 

## Efficient Portfolio

1. Consider two assets A and B with its Returns R, following independent and identically distributed 
   normal distributions
   
   $$R_i\ \sim\ i.i.d. \mathcal{N}(\mu_i,\,\sigma_i^2)$$
   
2. Portfolio Return and Portfolio Risk (variance) are stated as follows

$$\operatorname{E}(R_p) = w_A \operatorname{E}(R_A) + w_B \operatorname{E}(R_B)$$

$$\sigma_p^2  = w_A^2 \sigma_A^2  + w_B^2 \sigma_B^2 + 2w_Aw_B  \sigma_{A} \sigma_{B} \rho_{AB}$$


4. Therefore, Markowitz Modern Portfolio Theory states that Efficient Portfolios are the result of the
   minimization problem

$$ \underset{w_A, \; w_B}{\operatorname{arg\,min}} \; \sigma_p^2, \; \text{subject to:} \; w_A + w_B = 1\;$$


--- .class #id 

## App Outputs

1. First panel: Stock Price Monthly Evolution from 1998. (Time series)
2. Second panel: Stock Monthly Returns (Continuously Compounded Returns) (Time Series)
3. Third panel: Expected returns of efficient portfolio (efficient frontier) Vs. Risk of Efficient portfolios. 
                 Return and risk is also displayed for individual values, Global Minimum Variance portfolio and 
                 Tangency portfolio.
                 
4. Fourth panel: Portfolio composition given an expected level of return. Negative values imply short-shelling.
5. Sixth panel:  Table summarizing previous graph and calculating VaR for every Efficient Portfolio.

--- .class #id 

## Data Interpretation

For a given Expected Return (portfolio rate of return), the values associated to each stock represent the amount of the stock in the current portfolio. Negative values represent short-selling (sale of a security not owned by the seller or borrowed) and are counteracted by higher positive numbers. The summation of the position equals to 1.

VaR (Value at Risk) is estimated at a 5% level, meaning that there is a 5% probability that the portfolio will fail in value by the VaR amount calculated.

      
Check it here at [ShinyApps](https://frpportfolio.shinyapps.io/frpportfolio/)              
