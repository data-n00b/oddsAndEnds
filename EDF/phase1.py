"Arvind's EDF assessment. Phase I"

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

#Defining the date columns for ease of parsing when reading in the file.
dateCols1 = ['datetime_beginning_utc', 'datetime_beginning_ept', 'datetime_ending_utc', 'datetime_ending_ept']

loadData = pd.read_csv("loads.csv",parse_dates = dateCols1)

#Renaming columns for convenience
loadData.columns = ['bUTC' , 'bEPT' , 'eUTC' , 'eEPT', 'area', 'avgLoad']

#Groupping and plotting

#Plot size and window title
fig,ax=plt.subplots(figsize=(11,8))
fig.canvas.set_window_title('Hourly total loading for July 1st 2018')

#Managing ticks for x axis
tick_spacing = 1
loadData.groupby(['bUTC']).sum().plot(ax=ax)
ax.xaxis.set_major_locator(ticker.MultipleLocator(tick_spacing))
ax.tick_params(axis='x',which='both',direction = 'out', labelrotation = 45)

#Labels
ax.set_xlabel('Beginning Time in UTC Hours',fontsize = 20)
ax.set_ylabel('Total Load',fontsize = 20)
ax.set_title('Hourly total loading for July 1st 2018',fontsize = 24)
ax.get_legend().remove()

#Saving Figure to an exteral file and also displaying to the console.
#plt.savefig('hourly_loading_july_1st.jpg')
ax.grid(b=True,axis='y',color='r',linestyle='--')
plt.show()


dateCols2 = ['bid_datetime_beginning_utc', 'bid_datetime_beginning_ept']
offerData = pd.read_csv("offers.csv", parse_dates = dateCols2)

#List of unique units

#Given there are multiple units where bid1 data is missing/the same over the time period
#the data with the highest variability has been chosen for plotting purposes.

unitChoice = offerData.groupby(['unit_code'])['bid1'].describe()['std'].idxmax()

offerPlotData = offerData.groupby(['unit_code']).get_group(unitChoice)

plt.plot(offerPlotData.bid_datetime_beginning_utc,offerPlotData.bid1)
plt.show()
