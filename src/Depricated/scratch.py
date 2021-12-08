<<<<<<< HEAD
from datetime import timedelta
import simpy
import pandas as pd
import numpy as np

data_path = "./data/squeued.20211111.mergedparts2.csv"
sdata = pd.read_csv(data_path)
sdata = sdata.sort_values(by="SUBMIT_TIME")
l = pd.to_datetime(sdata["SUBMIT_TIME"]).sort_values().diff().dropna()

print(l[l > timedelta(hours=100)])

l = np.array([])
l.put


'''TODO:
    1) See what raising the number of nodes does to the gpu partition
    2) Lower the number of nodes in the other partitions until utilization balances out
=======
from datetime import timedelta
import simpy
import pandas as pd
import numpy as np

data_path = "./data/squeued.20211111.mergedparts2.csv"
sdata = pd.read_csv(data_path)
sdata = sdata.sort_values(by="SUBMIT_TIME")
l = pd.to_datetime(sdata["SUBMIT_TIME"]).sort_values().diff().dropna()

print(l[l > timedelta(hours=100)])

l = np.array([])
l.put


'''TODO:
    1) See what raising the number of nodes does to the gpu partition
    2) Lower the number of nodes in the other partitions until utilization balances out
>>>>>>> 0c83da474da9dc946a9e0495a147973edd76e933
'''