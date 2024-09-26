# Female Stress Phenotype

This is the github repository accompanying the paper: [**Data-driven analysis identifies female-specific modulation after chronic social defeat stress**](https://www.biorxiv.org/content/10.1101/2024.05.08.593167v1).

This repo contains code and data to reproduce analyses and main and supplementary figures and tables.\
Preprocessed data are included in the `./data/` folder. 
Full, unprocessed data can be found [here](https://osf.io/g3brw/).

------------------------------------------------------------------------

### Overview: Code for Figures

| Figure(s)     | Link to rendered html                                       | Path to code              |
|---------------|-------------------------------------------------------------|---------------------------|
| Fig 1         | [Standard SIT readouts in males and females](https://heike-s.github.io/FemaleStressPhenotype/code/01_SIRatio.html)                     | `./code/01_SIRatio.qmd`   |
| Fig 2, Fig S1 | [CSW/DS induced changes in frequency of behavioral syllables](https://heike-s.github.io/FemaleStressPhenotype/code/02_SylFreqs.html)   | `./code/02_SylFreqs.qmd`  |
| Fig 3, Fig S2 | [PCA; Changes in Up- and Downregulated syllables](https://heike-s.github.io/FemaleStressPhenotype/code/03_PCA.html)                    | `./code/03_PCA.qmd`       |
| Fig 4, Fig S3 | [Velocity as a heuristic](https://heike-s.github.io/FemaleStressPhenotype/code/04_DelVel.html)                                         | `./code/04_DelVel.qmd`    |
| Fig 5         | [Generalization to other female defeat models](https://heike-s.github.io/FemaleStressPhenotype/code/05_FemModels.html)                 | `./code/05_FemModels.qmd` |
| Fig 6, Fig S4 | [Defining resilience and susceptibility](https://heike-s.github.io/FemaleStressPhenotype/code/06_SI_DelVel.html)                       | `./code/06_SI_DelVel.qmd` |
| Fig 7         | [FIP mPFC to NAc susceptibility signature](https://heike-s.github.io/FemaleStressPhenotype/code/07_mPFC_FIP.html)                      | `./code/07_mPFC_FIP.qmd`  |

### Overview: Data for Figures

| Datafile | Description | Path to file | Figures | 
|----------|-------------|--------------|---------|
| Cohorts | Overview of cohorts and corresponding tests. | `./data/Cohorts.csv` | |
| SIT Raw (Primary) | SIT data for each trial in raw format, including syllable frequencies (i.e., two observations per aninmal) in primary CSW/DS dataset. |`./data/SIT_raw_primary.rds`| 1,S1,S3,S4 |
| SIT Difference (Primary) | SIT data that contain the ratio (IZ Time, Corner Time) or difference (all other variables) between trial types for each animal in primary CSW/DS dataset (i.e., single observation per animal). A copy of this df with added variables is created after Fig. 3 to include PCs and the SMS. |`./data/SIT_diff_primary.rds`, `./data/SIT_diff_primary_pcsms.rds`| 1,2,3,4,5,6 |
| SIT Difference (Secondary) | Same as SIT Difference (Primary), but in secondary datasets (i.e., CSNDS, Urine model, models of inter-female aggression). |`./data/SIT_diff_secondary.rds`| 5,6,S5 |
| SIT z-Scored (Primary) | Syllable frequencies of each syllable z-scored for each trial type (NT_z, T_z) and for the difference btween trial types (z_diff = NT_z - T_z). | `.data/SIT_z_primary.rds` | 2,3,S3 |
| Syllable information | Original syllable label, average frequency difference between NT and T trial as well as new label assigned based on social identity. | `./data/syllable_info.csv` | 3,4,5 |
| Syllable descriptives | Average syllable characteristics (Motion, Pose, Location) for each animal for each trial (NT, T). | `./data/SIT_syl_descriptives.rds` | 4 |
| OFT (Primary) | OFT data for each animal in primary CSW/DS dataset. | `./data/OFT_primary.rds` | S6 |
| FIP data | FIP data during SIT in Arena and IZ. | `./data/FIP_data.rds` | 7 |