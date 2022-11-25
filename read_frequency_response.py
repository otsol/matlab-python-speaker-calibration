import csv
import math
import os
from typing import List
import argparse
import numpy as np

import matplotlib.pyplot as plt

# command line argument parser with help messages
parser = argparse.ArgumentParser(description="Create Equalizer APO config from frequency"
                                             "response CSV")
parser.add_argument('sampling_frequency', metavar="Fs", type=int,
                    help="Give sampling frequency Fs (float)")
parser.add_argument("file_name", metavar="file", type=str, action="store",
                    help="Give file name of frequency response CSV file")
args = parser.parse_args()

# set sampling frequency from 2nd command line argument
Fs = args.sampling_frequency

# empty list for reading csv lines
a: List[float] = []
# open file
script_path = os.path.dirname(os.path.abspath(__file__))
print(os.path.join(script_path, args.file_name))
with open(os.path.join(script_path, args.file_name), newline='\n') as csvfile:
    x_reader = csv.reader(csvfile, delimiter=' ')
    for row in x_reader:
        print(', '.join(row))
        # add every row (a float number) to a Python list
        a.append(row)

# convert list to numpy array
c = np.array(a, float)
# create frequency vector for plots
f = np.linspace(1.0, 20000.0, num=len(c))
# plot and show
plt.plot(c)
plt.show()
plt.figure(figsize=(8, 2), dpi=160)
plt.plot(np.log10(f), c, color='green', linewidth=0.2)
plt.show()


# https://stackoverflow.com/questions/53345583/python-numpy-exponentially-spaced-samples-between-a-start-and-end-value
# similar function in stack overflow, log instead of exponential

# self-made helper function, returns numpy array of floats (probably)
# creates exponential spacing
# start first value of output array
# end last value of output array
# power exponential power that determinates spacing
# num number of array elements in total
def powspace(start, stop, power, num) -> np.ndarray:
    start = math.log(start, power)
    stop = math.log(stop, power)
    return np.power(power, np.linspace(start, stop, num=num))


# choose 32 points for creating an EQ profile
start = 32.0
end = 18000.0
eq_frequencies = powspace(start, end, 2, 32)
eq_frequencies = np.floor(eq_frequencies).astype(int)
print(eq_frequencies)

start_index = int(int(len(c) / 2) * (start / 20000))
end_index = int(int(len(c) / 2) * (end / 20000))
print(f'Start:{start_index}, End:{end_index}')
# eq_points = np.logspace(6, )
eq_indexes = powspace(start_index, end_index, 2, 32)
eq_indexes = np.floor(eq_indexes).astype(int)
print(eq_indexes)
plt.figure(figsize=(8, 2), dpi=160)
plt.plot(eq_indexes)
plt.show()

db_vals = np.ndarray.flatten(c[eq_indexes])
db_max_gain = np.max(db_vals)

with open("APO_config.txt", "w+") as f:
    f.write(f"Preamp: -{db_max_gain/5} dB\r\n")
    for index, freq in enumerate(eq_frequencies):
        f.write(f"Filter: ON PK Fc {freq} Hz Gain {db_vals[index]/5} dB Q 2\r\n")

print("Hello world")
