"Arvind's EDF assessment. Phase I"

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import datetime

#Defining the date columns for ease of parsing when reading in the file.
dateCols1 = ['datetime_beginning_utc', 'datetime_beginning_ept', 'datetime_ending_utc', 'datetime_ending_ept']

loadData = pd.read_csv("loads.csv",parse_dates = dateCols1)

#Renaming columns for convenience
loadData.columns = ['bUTC' , 'bEPT' , 'eUTC' , 'eEPT', 'area', 'avgLoad']

#V1 plot.
"""
Include ticks and change labels
"""
loadData.groupby(['bUTC']).sum().plot()
plt.show()

dateCols2 = ['bid_datetime_beginning_utc', 'bid_datetime_beginning_ept']
offerData = pd.read_csv("offers.csv", parse_dates = dateCols2)

#List of unique units

#Given there are multiple units where bid1 data is missing/the same over the time period
#the data with the highest variability has been chosen for plotting purposes.

unitChoice = offerData.groupby(['unit_code'])['bid1'].describe()['std'].idxmax()

offerPlotData = offerData.groupby(['unit_code']).get_group('AgAHBQ4OBA8dODkxODIxMDI')

plt.plot(offerPlotData.bid_datetime_beginning_utc,offerPlotData.bid1)
plt.show()
