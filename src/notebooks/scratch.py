%pylab inline

'''
Imports
'''
import functools
import itertools
import shelve

import simpy
import scipy.stats
import numpy as np
import pandas as pd
import statsmodels.api as sm

def patch_resource(resource, pre=None, post=None):
    """
    Patch *resource* so that it calls the callable *pre* before each
    put/get/request/release operation and the callable *post* after each
    operation. The only argument to these functions is the resource
    instance.

    Arguments:
        resource: The simpy.resources.container.Container to wrap.
        pre: The function to call before the wrapped function.
        post: The function to call after the wrapped function.
    """
    def get_wrapper(func):
        # Generate a wrapper for put/get/request/release
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # This is the actual wrapper
            # Call "pre" callback
            if pre:
                pre(resource)

            # Perform actual operation
            ret = func(*args, **kwargs)

            # Call "post" callback
            if post:
                post(resource)

            return ret
        return wrapper

    # Replace the original operations with our wrapper
    for name in ['put', 'get', 'request', 'release']:
        if hasattr(resource, name):
            setattr(resource, name, get_wrapper(getattr(resource, name)))
    return resource


def monitor(data, resource):
    """This is our monitoring callback."""
    data.append({
        "clock": resource._env.now,
        "usage": resource.capacity - resource.level,
        "queue": len(resource.get_queue),
        "total": resource.capacity - resource.level + len(resource.get_queue)
    })

# Path to the cleaned SeaWulf Job Scheduler data
data_path = "../../data/seawulf-data.20211111.final.csv"

# Path to the data gathered to determine the distribution of the requested number of nodes
node_data_path = "../../data/squeued.20211125.shelf"

'''
The below functions create samplers for the distributions related to this project;
    1) Interarrival Times
    2) Service Times
    3) Delay
    4) number of requested nodes
'''
def sampler(data):
    kde = sm.nonparametric.KDEUnivariate(data)
    kde.fit()
    icdf = scipy.interpolate.interp1d(np.linspace(0, 1, num=kde.icdf.size), kde.icdf)
    return lambda: icdf(np.random.uniform(0, 1))


def interarrival_sampler(partition):
    sdata = pd.read_csv(data_path).sort_values(by="SUBMIT_TIME")
    sdata = sdata[sdata.MERGED_PARTITION == partition]

    # Compute interarrival times in hours.
    interarrival_times = (pd.to_datetime(sdata["SUBMIT_TIME"]).sort_values().diff().dropna() / np.timedelta64(1, "h")).values
    return sampler(interarrival_times)


def service_sampler(partition):
    sdata = pd.read_csv(data_path).sort_values(by="SUBMIT_TIME")
    sdata = sdata[sdata.MERGED_PARTITION == partition]

    # Compute service times in hours.
    service_times = (pd.to_timedelta(sdata["SERVICE_TIME"].dropna()) / np.timedelta64(1, "h")).values
    return sampler(service_times)

def delay_sampler(partition):
    sdata = pd.read_csv(data_path).sort_values(by="SUBMIT_TIME")
    sdata = sdata[sdata.MERGED_PARTITION == partition]

    # Compute service times in hours.
    delay_times = (pd.to_timedelta(sdata["DELAY_TIME"].dropna()) / np.timedelta64(1, "h")).values
    return sampler(delay_times)

def nodes_sampler():
    with shelve.open(node_data_path) as db:
        df = pd.DataFrame(db.values())
    smplr = sampler(df.NODES)
    return lambda: int(smplr())

# Helper function that returns the capacity of the given partition of the SeaWulf Cluster
def get_capacity(partition):
    sdata = pd.read_csv(data_path)
    return len(sdata[sdata.MERGED_PARTITION == partition].EXEC_HOST.unique())

def simulate(partition="24core", until=24 * 150, capacity=100):
    '''
    Simulate the given partition of the SeaWulf Cluster for the given number of time steps.

    Arguments:
        partition: The SeaWulf partition to simulate
        until: The number of time steps to run the simulation
    '''
    interarrival = interarrival_sampler(partition)
    service = service_sampler(partition)
    nodes = nodes_sampler()

    # Lists to keep track of generated samples
    interarrivals_list = []
    start_list = []
    end_list = []
    delays_list = []
    service_list = []
    num_nodes_list = []
    
    def source(env, partition):
        cntr = itertools.count(start=0)
        while True:
            # Ensure the number of nodes requested does not exeed the partitions capacity.
            num_nodes = nodes()
            while num_nodes > capacity:
                num_nodes = nodes()
            
            # Update sample lists
            num_nodes_list.append(num_nodes)
            inter = interarrival()
            interarrivals_list.append(inter)

            # Wait for next arrival
            yield env.timeout(inter)
            start_list.append(env.now) # mark the start of time in the queue
            # A job has arrived.
            env.process(job(env, partition, next(cntr), num_nodes))


    def job(env, partition, idx, num_nodes):
        # Wait for the required number of nodes to be available.
        req = partition.get(num_nodes)
        yield req
        
        # The requested number of nodes are now available
        end_list.append(env.now) # mark the end of time in the queue

        # Update sample service time list
        ser = service()
        service_list.append(ser)

        yield env.timeout(ser)

        # Release the nodes back to the container
        rel = partition.put(num_nodes)
        yield rel
            

    # Setup the simpy.Environment to launch our simulator with.
    data = []
    env = simpy.Environment()
    partition = patch_resource(
        simpy.resources.container.Container(env, capacity=round(capacity), init=round(capacity)),
        pre=functools.partial(monitor, data)
    )
    env.process(source(env, partition))
    env.run(until=until)

    # Prepare the delay data
    start_list = start_list[:len(end_list)] # Only count the jobs that finished.
    delays_list = (np.array(end_list) - np.array(start_list))
    return (pd.DataFrame(data).set_index("clock"), interarrivals_list.copy(), delays_list.copy(), service_list.copy(), num_nodes_list.copy())

until1 = 24 * 90
until2 = 24 * 120
until3 = 24 * 540
until4 = 24 * 300

sim_24core = simulate(partition="24core", until=until1, capacity=get_capacity("24core"))
sim_24core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="24core")
sim_28core = simulate(partition="28core", until=until2, capacity=get_capacity("28core"))
sim_28core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="28core")
sim_40core = simulate(partition="40core", until=until3, capacity=get_capacity("40core"))
sim_40core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="40core")
sim_gpu = simulate(partition="gpu", until=until4, capacity=get_capacity("gpu"))
sim_gpu[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="gpu")

new_cap_24core = 85
new_cap_28core = 105
new_cap_40core = 75
new_cap_gpu = 30

sim2_24core = simulate(partition="24core", until=until1, capacity=new_cap_24core)
sim2_24core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="24core")
sim2_28core = simulate(partition="28core", until=until2, capacity=new_cap_28core)
sim2_28core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="28core")
sim2_40core = simulate(partition="40core", until=until3, capacity=new_cap_40core)
sim2_40core[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="40core")
sim2_gpu = simulate(partition="gpu", until=until4, capacity=new_cap_gpu)
sim2_gpu[0][1000:].plot(figsize=(30, 10), drawstyle="steps-post", subplots=True, title="gpu")

'''NOTE:
    sim_xxcore[1] are the interarrival times
    sim_xxcore[2] are the delay times
    sim_xxcore[3] are the service times
    sim_xxcore[4] are the number of requested nodes
'''

sim_dict = {"24core":sim_24core, "28core":sim_28core, "40core":sim_40core, "gpu":sim_gpu}
sim_dict2 = {"24core":sim2_24core, "28core":sim2_28core, "40core":sim2_40core, "gpu":sim2_gpu}
cap = {"24core":new_cap_24core, "28core":new_cap_28core, "40core":new_cap_40core, "gpu":new_cap_gpu}

print("\n\n\n")
for partition in ["24core", "28core", "40core", "gpu"]: 
    # Print out the statistics for the current partition
    print(f"Partition: {partition}")
    print(f"Original Simulation (n={len(sim_dict[partition][1])}):")
    print(f"Capacity: {get_capacity(partition)}")
    print("--------------------------------------------------")
    print(f"mean/min/max interarrival time:         {np.mean(sim_dict[partition][1]):0.5} | {np.min(sim_dict[partition][1]):0.5} | {np.max(sim_dict[partition][1]):0.5}")
    print(f"mean/min/max delay time:                {np.mean(sim_dict[partition][2]):0.5} | {np.min(sim_dict[partition][2]):0.5} | {np.max(sim_dict[partition][2]):0.5}")
    print(f"mean/min/max service time:              {np.mean(sim_dict[partition][3]):0.5} | {np.min(sim_dict[partition][3]):0.5} | {np.max(sim_dict[partition][3]):0.5}")
    print(f"mean/min/max number of requested nodes: {np.mean(sim_dict[partition][4]):0.5} | {np.min(sim_dict[partition][4])} | {np.max(sim_dict[partition][4])}")
    print(f"Average nodes in use: {(np.mean(sim_dict[partition][4])*np.mean(sim_dict[partition][3]))/(np.mean(sim_dict[partition][1]))}")
    print(f"Average utilization: {(np.mean(sim_dict[partition][4])*np.mean(sim_dict[partition][3]))/(np.mean(sim_dict[partition][1])*get_capacity(partition))}")
    print("--------------------------------------------------")
    print(f"Modified Capacities Simulation (n={len(sim_dict2[partition][1])}):")
    print(f"Capacity: {cap[partition]}")
    print("--------------------------------------------------")
    print(f"mean/min/max interarrival time:         {np.mean(sim_dict2[partition][1]):0.5} | {np.min(sim_dict2[partition][1]):0.5} | {np.max(sim_dict2[partition][1]):0.5}")
    print(f"mean/min/max delay time:                {np.mean(sim_dict2[partition][2]):0.5} | {np.min(sim_dict2[partition][2]):0.5} | {np.max(sim_dict2[partition][2]):0.5}")
    print(f"mean/min/max service time:              {np.mean(sim_dict2[partition][3]):0.5} | {np.min(sim_dict2[partition][3]):0.5} | {np.max(sim_dict2[partition][3]):0.5}")
    print(f"mean/min/max number of requested nodes: {np.mean(sim_dict2[partition][4]):0.5} | {np.min(sim_dict2[partition][4])} | {np.max(sim_dict2[partition][4])}")
    print(f"Average nodes in use: {(np.mean(sim_dict2[partition][4])*np.mean(sim_dict2[partition][3]))/(np.mean(sim_dict2[partition][1]))}")
    print(f"Average utilization: {(np.mean(sim_dict2[partition][4])*np.mean(sim_dict2[partition][3]))/(np.mean(sim_dict2[partition][1])*cap[partition])}\n")

'''
Actual data Statistics
'''
print("\n\n\n")
# Paths to data files
data_path = "../../data/seawulf-data.20211111.final.csv"
node_data_path = "../../data/squeued.20211125.shelf"

# Read in the Data
df = pd.read_csv(data_path).sort_values(by="SUBMIT_TIME")
with shelve.open(node_data_path) as db:
        df2 = pd.DataFrame(db.values())
num_nodes_list = df2.NODES

# Calculate sample data statistics
for partition in ["24core", "28core", "40core", "gpu"]:
    sdata = df[df.MERGED_PARTITION == partition]
    inter_list = (pd.to_datetime(sdata["SUBMIT_TIME"]).sort_values().diff().dropna() / np.timedelta64(1, "h")).values
    delay = delay_sampler(partition)
    del_list = (pd.to_timedelta(sdata["DELAY_TIME"].dropna()) / np.timedelta64(1, "h")).values
    serv_list = (pd.to_timedelta(sdata["SERVICE_TIME"].dropna()) / np.timedelta64(1, "h")).values
    cap = len(sdata.EXEC_HOST.unique())

    print(f"Partition: {partition}")
    print(f"Capacity: {cap}")
    print(f"mean/min/max interarrival time: {np.mean(inter_list):0.5} | {np.min(inter_list):0.5} | {np.max(inter_list):0.5}")
    print(f"mean/min/max service time: {np.mean(serv_list):0.5} | {np.min(serv_list):0.5} | {np.max(serv_list):0.5}")
    print(f"mean/min/max delay time: {np.mean(del_list):0.5} | {np.min(del_list):0.5} | {np.max(del_list):0.5}")
    print(f"mean/min/max number of requested nodes: {np.mean(num_nodes_list):0.5} | {np.min(num_nodes_list)} | {np.max(num_nodes_list)}")
    print(f"Average nodes in use: {(np.mean(num_nodes_list)*np.mean(serv_list))/(np.mean(inter_list))}")
    print(f"Average utilization: {(np.mean(num_nodes_list)*np.mean(serv_list))/(np.mean(inter_list)*cap)}\n")

'''
Sampler data Statistics
'''
print("\n\n\n")
n = 100000
for partition in ["24core", "28core", "40core", "gpu"]:
    # Create the samplers to generate the sample data
    interarrival = interarrival_sampler(partition)
    service = service_sampler(partition)
    nodes = nodes_sampler()

    # The capacity of the current partition
    cap = get_capacity(partition)

    inter_list = []
    serv_list = []
    num_nodes_list = []

    # Gather n sample points
    for i in range(n):
        # Ensure the number of requested nodes does not exeed the capacity
        num = nodes()
        while num > cap:
            num = nodes()

        inter_list.append(interarrival())
        serv_list.append(service())
        num_nodes_list.append(num)

    # Print out the statistics for the current partition
    print(f"Partition: {partition}")
    print(f"Capacity: {cap}")
    print(f"mean/min/max interarrival time: {np.mean(inter_list):0.5} | {np.min(inter_list):0.5} | {np.max(inter_list):0.5}")
    print(f"mean/min/max service time: {np.mean(serv_list):0.5} | {np.min(serv_list):0.5} | {np.max(serv_list):0.5}")
    print(f"mean/min/max number of requested nodes: {np.mean(num_nodes_list):0.5} | {np.min(num_nodes_list)} | {np.max(num_nodes_list)}")
    print(f"Average nodes in use: {(np.mean(num_nodes_list)*np.mean(serv_list))/(np.mean(inter_list))}")
    print(f"Average utilization: {(np.mean(num_nodes_list)*np.mean(serv_list))/(np.mean(inter_list)*cap)}\n")
