"Arvind's EDF assessment. Phase I"

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import datetime

#Defining the date columns for ease of parsing when reading in the file.
dateCols = ['datetime_beginning_utc', 'datetime_beginning_ept', 'datetime_ending_utc', 'datetime_ending_ept']

loadData = pd.read_csv("loads.csv",parse_dates = dateCols)

#Renaming columns for convenience
loadData.columns = ['bUTC' , 'bEPT' , 'eUTC' , 'eEPT', 'area', 'avgLoad']

#V1 plot.
"""
Include ticks and change labels
"""
loadData.groupby(['bUTC']).sum().plot()
