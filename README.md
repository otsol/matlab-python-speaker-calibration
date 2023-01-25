# SASP-speaker-cal-project

## Description
A speaker calibration software with MATLAB. The Python script uses a CSV file that MATLAB script outputs. Python script can create a configuration file
for real time EQ software Equalizer APO.

impulse.m - MATLAB speaker calibration script
createAPOConfig.py - Python script for Equalizer APO config files
EQAPO_configs/APO_config_Xtreme3_OK18_measurement2_256_fixed.txt - An example of Equalizer APO config file

## Installation
Created with MATLAB version R2022b, requires Signal Processing Toolbox.
Python script for creating Equalizer APO config file was created and tested with
Python 3.10.8. Required Python packages from pip are numpy and matplotlib.

## Usage
Run MATLAB script impulse.m and hear the difference in EQ. By default it
calibrates the JBL Xtreme speaker. Of course playing the audio from the same
JBL speaker would be optimal because the calibration is for that speaker only.

26.1.2023

By Aino, Juho, Kasperi and Otso