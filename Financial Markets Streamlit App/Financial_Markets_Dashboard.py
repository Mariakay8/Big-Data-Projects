# -*- coding: utf-8 -*-
"""
Created on Sat Nov 12 11:35:56 2022

@author: mkarakoulian1
"""

###############################################################################
# MY FINANCIAL DASHBOARD
###############################################################################

#==============================================================================
# LIBRARIES
#==============================================================================

import yfinance as yf
import streamlit as st
import pandas as pd
import numpy as np
import datetime
import matplotlib.pyplot as plt
import plotly.graph_objects as go
from datetime import datetime, timedelta
from numerize import numerize
from plotly.subplots import make_subplots
from PIL import Image

#==============================================================================
# HEADER
#==============================================================================

st.set_page_config(page_title='Financial Markets Dashboard', page_icon='🎯', initial_sidebar_state = 'auto')

# Add dashboard title and description
st.title("S&P500 Stock Performance")
st.write("Built by Maria Karakoulian 😎")

#==============================================================================
# SIDEBAR
#==============================================================================

# Add a subheader
st.sidebar.subheader("Choose a stock and start exploring!")
st.sidebar.info('Switch to dark mode for a better user experience', icon="ℹ️")

# Add an image
image = Image.open("Financial Markets Streamlit App/Pic.PNG")
st.sidebar.image(image, use_column_width=True)

# Get the list of stock tickers from S&P500
ticker_list = pd.read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies')[0]['Symbol']

# Add a dropdown menu to select the stock names
ticker = st.sidebar.selectbox('Select Ticker', ticker_list)

# Add a button to update the stock data
get = st.sidebar.button("Show Data 👈", key="get")

#==============================================================================
# MAIN BODY
#==============================================================================

# Create tabs and add tab titles
tab_titles = ["Summary", "Chart", "Financials", "Company Profile", "Shareholders", "Recommendations", "Monte Carlo Simulation"]
tabs = st.tabs(tab_titles)

# -----------------------------------TAB 1----------------------------------  

def Summary():
    
    @st.cache
    def GetStockInfo(ticker):
        return yf.Ticker(ticker).info
    
    # Add key figures
    info = GetStockInfo(ticker)
    
    volume = round((info['volume'] / 1000000), 2)
    cap = round((info['marketCap'] / 1000000000), 2)
    change = str(round(((info['currentPrice'] / info['previousClose']) -1), 2)) + "% Today"
    
    col1, col2, col3 = st.columns(3)        
    col1.metric(label="Current Price", value=round(info['currentPrice'],2), delta=change)
    col2.metric(label="Volume (Mn USD)", value=volume)
    col3.metric(label="Market Cap (Bn USD)", value=cap)
        
   
    @st.cache
    def GetStockPrice(ticker, period, interval):
        stock_price = yf.Ticker(ticker).history(period, interval)
        return stock_price.loc[:, 'Close']  
   
    # Add a chart for the close price for 8 different periods
    col1, col2, col3, col4, col5, col6, col7, col8 = st.columns(8)
    with col1:
        M1 = st.button("1M") 
    with col2:
        M3 = st.button("3M")
    with col3:
        M6 = st.button("6M")
    with col4:
        YTD = st.button("YTD")
    with col5:
        Y1 = st.button("1Y")
    with col6:
        Y3 = st.button("3Y")
    with col7:
        Y5 = st.button("5Y")
    with col8:
        MAX = st.button("MAX")

    if M1: 
        stock_price = GetStockPrice(ticker, period="1mo", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif M3: 
        stock_price = GetStockPrice(ticker, period="3mo", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif M6: 
        stock_price = GetStockPrice(ticker, period="6mo", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif YTD: 
        stock_price = GetStockPrice(ticker, period="ytd", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif Y1: 
        stock_price = GetStockPrice(ticker, period="1y", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif Y3: 
        stock_price = GetStockPrice(ticker, period="3y", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif Y5: 
        stock_price = GetStockPrice(ticker, period="5y", interval = "1d")
        st.area_chart(stock_price, width=700)
    elif MAX: 
        stock_price = GetStockPrice(ticker, period="max", interval = "1d")
        st.area_chart(stock_price, width=700)
    else:
        stock_price = GetStockPrice(ticker, period="1mo", interval = "1d")
        st.area_chart(stock_price, width=700)
        
    @st.cache
    def GetStockInfo(ticker):
        return yf.Ticker(ticker).info
    
    # Show the key indicators
    info = GetStockInfo(ticker) 
   
    col1, col2, col3 = st.columns(3)
    with col1:
        st.write('**Trading Information**')
        keys = ['open', 'dayHigh', 'dayLow']
        company_stats = {}  # Dictionary
        for key in keys:
            company_stats.update({key:(info[key])})
        company_stats = pd.DataFrame({'Value':pd.Series(company_stats)}).rename(index={'open': 'Open', 'dayHigh': 'High', 'dayLow': 'Low'}).style.format('{:.2f}')
        st.table(company_stats)
        
    with col2:
        st.write('**Valuation Measures**')
        keys = ['trailingPE', 'priceToBook', 'enterpriseToEbitda']
        company_stats = {}  # Dictionary
        for key in keys:
            company_stats.update({key:info[key]})
        company_stats = pd.DataFrame({'Value':pd.Series(company_stats)}).rename(index={'trailingPE': 'Price-to-Earnings', 'priceToBook': 'Price-to-Book', 'enterpriseToEbitda': 'EV/EBITDA'}).style.format('{:.2f}') 
        st.table(company_stats)  
    with col3:
        st.write('**Financial Highlights**')
        keys = ['grossMargins', 'debtToEquity', 'trailingEps']
        company_stats = {}  # Dictionary
        for key in keys:
            company_stats.update({key:info[key]})
        company_stats = pd.DataFrame({'Value':pd.Series(company_stats)}).rename(index={'grossMargins': 'Gross Margin', 'debtToEquity': 'Debt-to-Equity', 'trailingEps': 'Earnings-per-Share'}).style.format('{:.2f}')  
        st.table(company_stats)


# -----------------------------------TAB 2----------------------------------  
    
def Chart():
    
    # Plot a stock price chart with user defined periods, intervals and plot types
    #periods = {'1mo': '1M', '3mo': '3M', '6mo': '6M', 'ytd': 'YTD', '1y': '1Y', '3y': '3Y', '5y': '5Y', 'max': 'MAX'}
    #intervals = {'1d': '1D', '1mo': '1M', '1y': '1Y'}
    
    col1, col2, col3, col4, col5 = st.columns(5)
    start_date = col1.date_input("Select Start Date", datetime.today().date() - timedelta(days=30))
    end_date = col2.date_input("Select End Date", datetime.today().date())
    duration = col3.selectbox("Select Duration", ['Date Range', '1mo', '3mo', '6mo', 'ytd','1y', '3y','5y', 'max'])          
    interval = col4.selectbox("Select Interval", ['1d', '1mo', '1y'])
    plot = col5.selectbox("Select Plot", ['Candle', 'Line'])
    
    @st.cache
    def GetStockData(ticker):
        stock_price = yf.download(ticker, period = 'MAX')
        stock_price = stock_price.reset_index()
        
        if duration != 'Date Range':        
            stock_price = yf.download(ticker, period = duration, interval = interval)
            stock_price = stock_price.reset_index()
            return stock_price
        else:
            stock_price = yf.download(ticker, start_date, end_date, interval = interval)
            stock_price = stock_price.reset_index()
            return stock_price
        
    stock_price = GetStockData(ticker) 
    
    fig = make_subplots(specs=[[{"secondary_y": True}]])
    
    if plot == 'Candle':
        fig.add_trace(go.Candlestick(x=stock_price['Date'], open=stock_price['Open'], high=stock_price['High'], low=stock_price['Low'], close=stock_price['Close'],increasing_fillcolor= 'red', increasing_line_color='rgba(0, 0, 0, 0)',decreasing_fillcolor= 'cyan',decreasing_line_color='rgba(0, 0, 0, 0)'))
        fig.add_trace(go.Bar(x = stock_price['Date'], y = stock_price['Volume'], name = 'Volume', marker_color = 'white', marker_line_color='rgba(0, 0, 0, 0)'), secondary_y = True)
        fig.add_trace(go.Scatter(x=stock_price['Date'], y=stock_price['Close'].rolling(50).mean(), opacity=0.7, line=dict(color='yellow', width=2), name='50-Day MA'))
        fig.update_xaxes(rangebreaks=[dict(bounds=["sat", "mon"])])
        fig.update_xaxes(showspikes=True, spikemode="across", spikesnap="cursor", showline=False, spikedash="dot", spikecolor="white", spikethickness=0.1)
        fig.update_yaxes(showspikes=True, spikemode="across", spikesnap="cursor", showline=False, spikedash="dot", spikecolor="white", spikethickness=0.1)
        fig.update_yaxes(range=[0, stock_price['Volume'].max()*5], autorange=False, showticklabels=False, secondary_y=True, showgrid=False)
        fig.update_layout(margin=go.layout.Margin(l=20, r=20, b=20, t=20))
        fig.update_layout({'plot_bgcolor': 'rgba(0, 0, 0, 0)',
                           'paper_bgcolor': 'rgba(0, 0, 0, 0)',}, 
                           autosize=True, width=750, height=330,
                           xaxis=dict(showgrid=False),
                           yaxis=dict(showgrid=False),
                           xaxis_rangeslider_visible=False,
                           showlegend = False)
        
    elif plot == 'Line':
        fig.add_trace(go.Scatter(x=stock_price['Date'], y=stock_price['Close'], mode='lines', name = 'Close', marker_color = 'cyan'), secondary_y = False)
        fig.add_trace(go.Bar(x = stock_price['Date'], y = stock_price['Volume'], name = 'Volume', marker_color = 'white', marker_line_color='rgba(0, 0, 0, 0)'), secondary_y = True)
        fig.add_trace(go.Scatter(x=stock_price['Date'], y=stock_price['Close'].rolling(50).mean(), opacity=0.7, line=dict(color='yellow', width=2), name='50-Day MA'))
        fig.update_xaxes(rangebreaks=[dict(bounds=["sat", "mon"])])
        fig.update_xaxes(showspikes=True, spikemode="across", spikesnap="cursor", showline=False, spikedash="dot", spikecolor="white", spikethickness=0.1)
        fig.update_yaxes(showspikes=True, spikemode="across", spikesnap="cursor", showline=False, spikedash="dot", spikecolor="white", spikethickness=0.1)
        fig.update_yaxes(range=[0, stock_price['Volume'].max()*5], autorange=False, showticklabels=False, secondary_y=True, showgrid=False)
        fig.update_layout(margin=go.layout.Margin(l=20, r=20, b=20, t=20))
        fig.update_layout({'plot_bgcolor': 'rgba(0, 0, 0, 0)',
                           'paper_bgcolor': 'rgba(0, 0, 0, 0)',}, 
                           autosize=True, width=750, height=330,
                           xaxis=dict(showgrid=False),
                           yaxis=dict(showgrid=False),
                           xaxis_rangeslider_visible=False,
                           showlegend = False)
    
    st.plotly_chart(fig)
   
    # Add options to view historical data and export to excel
    col1, col2 = st.columns([4,1])
    show_data = col1.checkbox("Show Historical Data")
    export_data = col2.button("Export to Excel")

    if show_data:
        stock_price = stock_price.sort_values('Date', ascending=False)
        stock_price = stock_price.set_index('Date')
        stock_price = stock_price.style.format({'Open': '{:,.2f}'.format,
                                   'High': '{:,.2f}'.format,
                                   'Low': '{:,.2f}'.format,
                                   'Close': '{:,.2f}'.format,
                                   'Adj Close': '{:,.2f}'.format,
                                   'MA': '{:,.2f}'.format,
                                   'Volume': '{:0,.0f}'.format})
        st.table(stock_price)
    
    if export_data:
       stock_price.to_excel(r'C:/Users/mkarakoulian1/Desktop/export_dataframe.xlsx', index=False)

# -----------------------------------TAB 3----------------------------------              

def Financials():
    
    # Show the company's annual and quarterly financial statements 
    statements = ['Income Statement', 'Balance Sheet', 'Cash Flow']
    periods = ['Annual', 'Quarterly']
    
    col1, col2 = st.columns(2)
    with col1:
        select_st = st.selectbox('Select Statement', statements)
    with col2:
        select_pd = st.selectbox('Select Period', periods)      
    
    @st.cache
    def IS_Annual(ticker):
        return yf.Ticker(ticker).financials
    
    @st.cache
    def IS_Quarterly(ticker):
        return yf.Ticker(ticker).quarterly_financials
            
    @st.cache
    def BS_Annual(ticker):
        return yf.Ticker(ticker).balance_sheet
    
    @st.cache
    def BS_Quarterly(ticker):
        return yf.Ticker(ticker).quarterly_balance_sheet
    
    @st.cache
    def CF_Annual(ticker):
        return yf.Ticker(ticker).cashflow
    
    @st.cache
    def CF_Quarterly(ticker):
        return yf.Ticker(ticker).quarterly_cashflow
   
    if select_st == 'Income Statement' and select_pd == 'Annual':
        df = IS_Annual(ticker)
        df.columns = df.columns.astype(str)  
        df = df.loc[['Total Revenue', 'Operating Income', 'Cost Of Revenue', 'Gross Profit', 'Total Operating Expenses', 'Operating Income', 'Income Before Tax', 'Ebit', 'Interest Expense', 'Income Tax Expense', 'Net Income From Continuing Ops']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
    elif select_st == 'Income Statement' and select_pd == 'Quarterly':
        df = IS_Quarterly(ticker)
        df.columns = df.columns.astype(str)
        df = df.loc[['Total Revenue', 'Operating Income', 'Cost Of Revenue', 'Gross Profit', 'Total Operating Expenses', 'Operating Income', 'Income Before Tax', 'Ebit', 'Interest Expense', 'Income Tax Expense', 'Net Income From Continuing Ops']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
    elif select_st == 'Balance Sheet' and select_pd == 'Annual':
        df = BS_Annual(ticker)
        df.columns = df.columns.astype(str)
        df = df.loc[['Total Assets', 'Total Current Assets', 'Cash', 'Net Receivables', 'Inventory', 'Total Liab', 'Total Current Liabilities', 'Accounts Payable', 'Property Plant Equipment', 'Total Stockholder Equity']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
    elif select_st == 'Balance Sheet' and select_pd == 'Quarterly':
        df = BS_Quarterly(ticker)
        df.columns = df.columns.astype(str)
        df = df.loc[['Total Assets', 'Total Current Assets', 'Cash', 'Net Receivables', 'Inventory', 'Total Liab', 'Total Current Liabilities', 'Accounts Payable', 'Property Plant Equipment', 'Total Stockholder Equity']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
    elif select_st == 'Cash Flow' and select_pd == 'Annual':
        df = CF_Annual(ticker)
        df.columns = df.columns.astype(str)
        df = df.loc[['Total Cash From Operating Activities', 'Net Income', 'Depreciation', 'Total Cashflows From Investing Activities', 'Capital Expenditures', 'Total Cash From Financing Activities',  'Dividends Paid', 'Issuance Of Stock', 'Change In Cash']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
    elif select_st == 'Cash Flow' and select_pd == 'Quarterly':
        df = CF_Quarterly(ticker)
        df.columns = df.columns.astype(str)
        df = df.loc[['Total Cash From Operating Activities', 'Net Income', 'Depreciation', 'Total Cashflows From Investing Activities', 'Capital Expenditures', 'Total Cash From Financing Activities',  'Dividends Paid', 'Issuance Of Stock', 'Change In Cash']]
        df = df / 1000
        df = df.style.format('{:0,.0f}')
        st.caption("Values are in Thousands USD")
        st.table(df)
        
# -----------------------------------TAB 4----------------------------------        

def Profile():
  
  @st.cache
  def GetCompanyInfo(ticker):
      return yf.Ticker(ticker).info
  
  # Show the company information and business description
  info = GetCompanyInfo(ticker)
     
  name = info['shortName']
  st.header('**%s**' % name)
  st.image(info['logo_url'])
  st.write('**Sector:**', info['sector'])
  st.write('**Industry:**',info['industry'])
  st.write('**Employees:**', str(info['fullTimeEmployees']))
  st.write(info['website'])
       
  st.write('**Business Description:**')
  st.write(info['longBusinessSummary'])

def Shareholders():
    
    # Get the company's shareholder information
    @st.cache
    def GetMajorHolders(ticker):
        for tick in ticker:
            holders = yf.Ticker(tick).major_holders
            holders = holders.rename(columns={0:"Value", 1:"Breakdown"})
            holders = holders.set_index('Breakdown')
            holders.loc[['Number of Institutions Holding Shares']].style.format({'Number of Institutions Holding Shares': '{:0,.0f}'.format})
        return holders
    
   
    holders = GetMajorHolders([ticker])
    st.write('**Major Holders**')
    st.table(holders)
    
    @st.cache
    def GetInstHolders(ticker):
        for tick in ticker:
            inst_holders = yf.Ticker(tick).institutional_holders
            inst_holders['Shares'] = [numerize.numerize(y) for y in  inst_holders['Shares']]
            inst_holders['Value'] = [numerize.numerize(y) for y in  inst_holders['Value']]
            #inst_holders = inst_holders.style.format({'% Out': '{:0,.0f}'.format})
            inst_holders = inst_holders.set_index('Holder')
        return inst_holders
    
   
    inst_holders = GetInstHolders([ticker])
    st.write('**Top Institutional Holders**')
    st.table(inst_holders)
    
    @st.cache
    def GetFundHolders(ticker):
        for tick in ticker:
            fund_holders = yf.Ticker(tick).fund_holders
            fund_holders['Shares'] = [numerize.numerize(y) for y in  fund_holders['Shares']]
        return fund_holders
    
    
    fund_holders = GetInstHolders([ticker])
    st.write('**Top Mutual Fund Holders**')
    st.table(fund_holders)

# -----------------------------------TAB 5----------------------------------  

def Recommendations():
    
    # Show the analysts' recommendations concerning the stock
    @st.cache
    def GetRecInfo(ticker):
        rec = yf.Ticker(ticker).recommendations
        return rec
    
    rec = GetRecInfo(ticker)
    st.write('**Stock Ratings**')

    def Color(grade):
        color = 'green' if grade == 'Buy' else None
        return f'background-color: {color}'

    st.table(rec.style.applymap(Color, subset=['To Grade']))

# -----------------------------------TAB 6----------------------------------  

def MonteCarlo():
    
    # Conduct the Monte Carlo simulation for user defined number of simulations and time horizons
    n_simulation = [200, 500, 1000]
    time_horizon = [30, 60 ,90]
    
    col1, col2 = st.columns(2)
    select_ns = col1.selectbox('Select Number of Simulations', n_simulation)
    select_th = col2.selectbox('Select Time Horizon', time_horizon)      
    
    @st.cache
    def Simulation(ticker, select_th, select_ns):
        
       
        end_date = datetime.now().date() 
        start_date = end_date - timedelta(days=30)
        
        # Extract the close price
        stock_price = yf.Ticker(ticker).history(start=start_date, end=end_date)
        close_price = stock_price['Close']
     
        # Calculate the financial metrics
        daily_return = close_price.pct_change()
        daily_volatility = np.std(daily_return)
     
        #Initialize the simulation dataframe    
        simulation_df = pd.DataFrame()
     
        for i in range(select_ns):
    
            # The list to store the next stock price
            next_price = []
    
            # Create the next stock price
            last_price = close_price[-1]
    
            for t in range(select_th):
                                   
                # Generate the random percentage change around the mean (0) and std (daily_volatility)
                future_return = np.random.normal(0, daily_volatility)
    
                # Generate the random future price
                future_price = last_price * (1 + future_return)
    
                # Save the price and go next
                next_price.append(future_price)
                last_price = future_price
    
            # Store the result of the simulation
            next_price_df = pd.Series(next_price).rename('sim' + str(i))
            simulation_df = pd.concat([simulation_df, next_price_df], axis=1)
        
        return simulation_df  
        
    
    mc = Simulation(ticker, select_th, select_ns)
    
    end_date = datetime.now().date() 
    start_date = end_date - timedelta(days=30)
    
    # Extract the close price
    stock_price = yf.Ticker(ticker).history(start=start_date, end=end_date)
    close_price = stock_price['Close']
    
    # Price at 95% confidence interval
    future_price_95ci = np.percentile(mc.iloc[-1:, :].values[0, ], 5)
    
    # Value at Risk
    VaR = stock_price['Close'][-1] - future_price_95ci
    
    st.write('Monte Carlo simulation for ' + ticker + ': Stock price in next ' + str(select_th) + ' days')
    
    fig, ax = plt.subplots()
    fig.set_size_inches(15, 10, forward=True)
    ax.plot(mc)
    
    plt.xlabel('Day', fontsize=15)
    plt.ylabel('Close Price', fontsize=15)

    plt.axhline(y=stock_price['Close'][-1], color='red')
    fig.patch.set_facecolor('none')
    ax.set_facecolor('none')
    ax.xaxis.label.set_color('white')        
    ax.yaxis.label.set_color('white')
    ax.spines['left'].set_color('white') 
    ax.spines['bottom'].set_color('white') 
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.tick_params(axis='x', colors='white')
    ax.tick_params(axis='y', colors='white')
    st.pyplot(fig)
            
    # Get the ending price of the 200th day
    ending_price = mc.iloc[-1:, :].values[0, ]
    
    # Plot using histogram
    st.write('VaR at 95% Confidence Interval is ' + str(np.round(VaR, 2)) + ' USD')
    fig1, ax = plt.subplots()
    ax.hist(ending_price, color='cyan', bins=50)
    plt.axvline(x=stock_price['Close'][-1], color='red')       
    fig1.patch.set_facecolor('none')
    ax.set_facecolor('none')
    ax.xaxis.label.set_color('white')        
    ax.yaxis.label.set_color('white')
    ax.spines['left'].set_color('white') 
    ax.spines['bottom'].set_color('white') 
    ax.tick_params(axis='both', which='major', labelsize=6)
    ax.tick_params(axis='x', colors='white')
    ax.tick_params(axis='y', colors='white')
    
    st.pyplot(fig1)
    
# Run the tab informations               
with tabs[0]:
    Summary()
with tabs[1]:
    Chart()
with tabs[2]:
    Financials()
with tabs[3]:
    Profile()
with tabs[4]:
    Shareholders()
with tabs[5]:
    Recommendations()
with tabs[6]:
    MonteCarlo()
    
###############################################################################
# THE END
###############################################################################
