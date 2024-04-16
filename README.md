# Female Stress Phenotype

This is the github repository accompanying the paper: **Data-driven analysis identifies female-specific modulation after chronic social defeat stress**.\
BIORXIV LINK.\

This repo contains code and data to reproduce analyses and main and supplementary figures and tables.\
Preprocessed data are included in the `./data/` folder. 
Full, unprocessed data can be found here:\
DATA REPO LINK.\

------------------------------------------------------------------------

### Overview: Code for Figures

| Figure(s)     | Link to rendered html                                       | Path to code              |
|------------------|----------------------------------|--------------------|
| Fig 1         | Standard SIT readouts in males and females                  |                           |
| Fig 2, Fig S1 | CSW/DS induced changes in frequency of behavioral syllables |                           |
| Fig 3, Fig S2 | PCA; Changes in Up- and Downregulated syllables             |                           |
| Fig 4, Fig S3 | Velocity as a heuristic                                     | `./code/04_DelVel.qmd`    |
| Fig 5         | Generalization to other female defeat models                | `./code/05_FemModels.qmd` |
| Fig 6, Fig S4 | Defining resilience and susceptibility                      | `./code/06_SI_DelVel.qmd` |
| Fig 7         | FIP mPFC to NAc susceptibility signature                    | `./code/07_mPFC_FIP.qmd`  |

### Overview: Data for Figures

| Datafile     | Description                                     | Path to file              | Figures | 
|--------------------------|----------------------------------|--------------------|------------------|
|SIT Raw (Primary) | SIT data for each trial in raw format, including syllable frequencies (i.e., two observations per aninmal) |`./data/SIT_raw_primary.rds`| 1,S1,S3 |
|SIT Difference (Primary) | SIT data that contains the ratio (IZ Time, Corner Time) or difference (all other variables) between trial types for each animal in the primary cohort (i.e., single observation per animal)|`./data/SIT_diff_primary.rds`| 1,2,3,4,5,6, |
|SIT Difference z-Scored (Primary) | 