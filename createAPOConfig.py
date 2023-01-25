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
parser.add_argument("eq_strength", metavar="EQStrength", type=float,
                    help="Give strength of output EQ filter (float), range 0-1, larger number=more strongly altered "
                         "response")
args = parser.parse_args()

# set sampling frequency from 2nd command line argument
Fs = args.sampling_frequency
# set filter intensity from 3rd command line argument
EQStrength = args.eq_strength

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


# choose filterlength points for creating an EQ profile
filterlength = 256
REW_multiply_constant = 20000 / 24000  # REW's generated frequency response goes up to mic samplerate/2=24000hz,
# so have to multiply the frequencies to align them correctly
start = 53.0 * REW_multiply_constant
end = 20000.0 * REW_multiply_constant
eq_frequencies = powspace(start, end, 2, filterlength)
eq_frequencies = np.floor(eq_frequencies).astype(int)
print("eq_frequencies")
print(eq_frequencies)

start_index = int(int(len(c)) * (start / 20000))
end_index = int(int(len(c)) * (end / 20000) - 1)
print(f'Start:{start_index}, End:{end_index}')
# eq_points = np.logspace(6, )
eq_indexes = powspace(start_index, end_index, 2, filterlength)
eq_indexes = np.floor(eq_indexes).astype(int)
print(eq_indexes)
plt.figure(figsize=(8, 2), dpi=160)
plt.plot(eq_indexes)
plt.show()

db_vals = np.ndarray.flatten(c[eq_indexes])
db_max_gain = np.max(db_vals)

with open("APO_config_Xtreme3_OK18_measurement2_256_fixed.txt", "w+") as f:
    f.write(f"Preamp: -{math.ceil(db_max_gain * EQStrength)} dB\r\n")
    for index, freq in enumerate(eq_frequencies):
        f.write(
            f"Filter: ON PK Fc {math.floor(freq * (1 / REW_multiply_constant))} Hz Gain {min(round(db_vals[index] * EQStrength, 2), 10)} dB Q 33.33\n")
