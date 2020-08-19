# high-frequency-activity-paper

Derived data and Matlab (Natick, MA) scripts to support the following publication: *[Reference to be inserted after acceptance of the manuscript.]*

Scripts are licensed under GPLv3.

Derived data is licensed for educational use only, with no warrenty implied.  ***Requests must be made with the corresponding author for any other use of the data, including additional research.***

## Instructions

1. Clone the repository
2. Open matlab
3. Run `full_procol`

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
getNumStars.m           | Auxillery function to determine the number of stars (enumerated of significance) for a given p-value
predictionAnalysis.m    | Main function to perform the prediction analysis (Section 2.4 of Stovall et al., 2020).
transformFeatures.m     | Auxillery function to apply transformations (log or atan) to the feature values.
