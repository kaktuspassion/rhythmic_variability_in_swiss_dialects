# Rhythmic Variability in Swiss German Dialects

November 2023



## Project Overview

This project explores the rhythmic variability across Swiss German dialects using acoustic metrics. By analyzing a corpus of speech samples from ***Basel, Bern, and Zurich***, we aim to investigate *how different rhythmic metrics can classify these dialects effectively*.

## Objectives

- To determine if metrics like *nPVI* and *VarcoV* can distinguish between the dialects of Basel, Bern, and Zurich.
- To evaluate the hypothesis using *Linear Discriminant Analysis (LDA)* based on selected rhythmic metrics.

## Dataset

The dataset includes recordings from *24 speakers* representing three Swiss German dialects. Each dialect is analyzed to capture unique rhythmic patterns using *Praat* software.

## Metrics Used

- **nPVI_C (Normalized Pairwise Variability Index for consonantal intervals):** Measures the variability in consonantal intervals.
- **VarcoV (Variation Coefficient of vocalic interval duration):** Calculates the standard deviation of vocalic intervals normalized by the mean.

## Methodology

1. **Pre-processing:** Speech samples are annotated to identify consonant and vowel intervals.
2. **Feature Extraction:** Metrics such as nPVI_C and VarcoV are calculated.
3. **Modeling:** LDA is used to classify the dialects based on the extracted features.
4. **Evaluation:** The model's performance is assessed using accuracy and confusion matrices.

## Results

The LDA model demonstrated moderate accuracy in distinguishing between the dialects, with specific challenges in classifying certain classes effectively.

## References

- Abercrombie, D. (1967). Elements of general phonetics.
- Ramus, F., Nespor, M., & Mehler, J. (1999). Correlates of linguistic rhythm in the speech signal.
- Leemann, Adrian et al. (2012). Rhythmic variability in Swiss German dialects.