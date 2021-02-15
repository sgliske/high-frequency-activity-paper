# high-frequency-activity-paper

Derived data and Matlab (Natick, MA) scripts to support the following publication: *[Reference to be inserted after acceptance of the manuscript.]*

Scripts are licensed under GPLv3.

Derived data is licensed for educational use only, with no warrenty implied.  ***Requests must be made with the corresponding author for any other use of the data, including additional research.***

## Parameter key

The data files names, and several of the scripts, use a parameter key in the form of

`'width-<www>.mask-<x><y>.nBands-<z>'`.
  
  * The width values refer to the width of the epoch.  Data was
    computed with values of `<www>` being 120, 300, or 600 (in units
    of seconds).
  
  * The mask parameter `<x>` specifies whether HFOs were rejected and
    the mask parameter `<y>` specifies whether artifacts were
    redacated: 1 == redacted, 0 == not redacted.

  * The number of bands parameter `<z>` specifies whether to use the
    data from the 2 or 3 band option.  See text of the manuscript for
    the specific frequency bands used.

  * The parameter key for the main results is `'width-300.mask-11.nBands-2'`

## Instructions

1. Clone the repository
2. Open matlab
3. Run `full_protocol(paramKey)` with `paramKey` being a string as described above.

## Scripts

### Main functions

Filename                | Description
----------------------- | ------------
full_protocol.m         | Main entry point to the code.  This scripts calls all needed functions to reproduce the analysis, results, and plots of the paper
inferenceAnalysis.m     | Main function to perform the inference (Internal Association) analysis (See Section 2.3 of Stovall et al., 2020).
predictionAnalysis.m    | Main function to perform the prediction analysis (Section 2.4 of Stovall et al., 2020).

### Plotting functions

Filename                | Description
----------------------- | ------------
plotRawData.m           | Raw data plot (Fig. 1)
plotFeatureExample.m    | Example features (Fig. 2)
plotInferenceResults.m  | Inference results (Fig. 3)
plotScorePerchannel.m   | pHFA Score per channel (Fig. 4)
plotPredictionResults.m | Prediction results (Fig. 5)

### Auxillery functions

Filename                | Description
----------------------- | ------------
adjustFeatures.m        | Auxillery function to adjust features based on the median value overall channels for a given epoch
computeAsym.m           | Auxillery function to compute asymmetries
gbar.m                  | Auxillery function to plot bar plots with multiple groups
getNumStars.m           | Auxillery function to determine the number of stars (enumerated of significance) for a given p-value
predictionAnalysis.m    | Main function to perform the prediction analysis (Section 2.4 of Stovall et al., 2020).
transformFeatures.m     | Auxillery function to apply transformations (log or atan) to the feature values.

## Derived (input) data

Filename                    | Description
--------------------------- | ------------
data-input/hfo_rates.mat    | HFO rates for comparison
data-input/raw-data.mat     | Short sample of raw data (for Fig. 1)
data-input/UMHS-00*.hfa.mat | Features of each epoch per channel and related metadata.

## Other files

Filename        | Description
----------------|----------------
Fig-3-table.csv | Table of values to support Figure 3.
Fig-5-table.csv | Table of values to support Figure 5.
