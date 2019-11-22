## FlexEMG_V2: A wearable biosensing system with printed flexible electrodes and in-sensor adaptive learning

This repository provides the offline dataset and MATLAB scripts used to verify the data acquision functionality of our device and the utilized algorithm. It is publicly available under GNU General Public License v3.

### System requirements
- MATLAB (MathWorks, Inc.). Tested on version R2019a.

### Repo structure
Note that all scripts are commented with function descriptions, input arguments, returns, etc.

- **`dataset/`**: Dataset containing raw EMG signals from 5 subjects and 21 hand gestures with 5 repeatitions  of each.
- **`functions/`**: MATLAB functions to emulate the HD algorithm being run on the on-board FPGA.

### Sample usage

To find the classification accuracy for subject 1 without using parallel computing toolbox, all you need to do is running `all_expermients` function in the following way:

> `all_expermients(1, 0)`

The results will be saved in **`output/`** folder.

### Problems?
If you face any problems or discover any bugs, please let us know: *MyLastName AT berkeley DOT edu*
