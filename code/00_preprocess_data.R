### Preprocess kpMoSeq + EthoVision / AnyMaze output into dataframes 
# This script is converting the data from multiple outputs into the dataframes
# used for analyses. The data used are stored in the corresponding OSF directory.
# and all outputs are saved in the data folder in the GitHub repo.

## Prep Environment ----
library(rhdf5)
library(dplyr)
library(tidyr)
library(here)

##### PRIMARY SIT #####
## Process MoSeq ----
exps = list.files('Data/kpMoSeq/') # dir contains one dir for each experiment
data = list()

# Read individual h5 files
for (exp in exps) {
  print(paste('Reading:', exp))
  results_file = paste0(path, 'Data/kpMoSeq/', exp)
  files = unique(h5ls(results_file)$group)
  files = files[2:length(files)]
  files = gsub('/', '', files)
  for (file in files) {
    cohort = strsplit(file, '_')[[1]][1]
    id = strsplit(file, '_')[[1]][3]
    trial_type = strsplit(file, '_')[[1]][4]
    data[[paste0(cohort, '_', id, '_', trial_type)]] = h5read(results_file, file)
  }
}

# Prepare sample data frame
SIT_data = unlist(lapply(data, '[', 'syllables'))
SIT_data = tibble('id_full' = as.vector.data.frame(gsub('\\..*', '', names(SIT_data))),
                  'syllable' = as.vector.data.frame(SIT_data))

# Identify syllables > 12 frames in at least one cohort
SIT_data %>%
  separate(id_full, c('cohort','id','trial_type'), '_', remove = F) %>%
  group_by(id_full, cohort, id, trial_type, syllable) %>%
  summarise(freq = n()) -> SIT_data

SIT_data %>%
  group_by(cohort, syllable) %>%
  summarise(avg_freq = mean(freq, na.rm = TRUE)) %>%
  filter(avg_freq > 15) %>%
  group_by(syllable) %>%
  summarise(syl_filt_freq = n()) %>%
  filter(syl_filt_freq == 20) -> syls_filtered

# Format df and add standard SIT metrics
SIT_data %>%
  filter(syllable %in% syls_filtered$syllable) %>%
  pivot_wider(id_cols = c('id_full','cohort','id','trial_type'),
              values_from = freq, names_from = syllable,
              names_prefix = 'syl', values_fill = 0) -> SIT_data

vertical <- c('E01','E02','E03','E04','E06','E07','E08','E18','E19') # placement of target enclosure

## Join with EhtoVision / AnyMaze data ----
etho_data <- read.csv('EthoVision_AnyMaze/primary_CSWDS_SIT_results.csv')
etho_data %>%
  mutate(id_full = paste(cohort_id, applied_ID, Trial_type, sep='_'),
         target_x = ifelse(cohort_id %in% vertical, 96, 192),
         target_y = ifelse(!(cohort_id %in% vertical), 96,
                           ifelse((cohort_id %in% vertical) & (Arena == 'Arena 1'), 192, 0))) -> etho_data

etho_data %>%
  left_join(SIT_data, by = 'id_full') %>%
  mutate(IZ_latency = as.numeric(IZ_latency)) %>%
  relocate(where(is.character)) %>%
  select(-c(Trial, Arena, ID, Time_to_Record,
            trial_type, cohort_id, applied_ID)) %>%
  relocate(c('id_full', 'cohort', 'id')) %>%
  na.omit() -> SIT_raw

# Make difference / ratio data frame
SIT_raw %>%
  select(-id_full) %>%
  pivot_longer(cols = !c('cohort', 'id', 
                         'Sex', 'Condition', 'Trial_type',
                         'target_x', 'target_y'), 
               names_to = 'metric', values_to = 'values') %>%
  pivot_wider(id_cols = c('cohort', 'id', 
                          'Sex', 'Condition', 'metric',
                          'target_x', 'target_y'), 
              names_from = 'Trial_type', values_from = 'values') %>%
  mutate(diff = ifelse(metric %in% c('IZ_time', 'Corner_time',), 
                       Target / `No Target`, 
                       `No Target` - Target)) %>%
  select(-c(`No Target`, Target)) %>%
  pivot_wider(id_cols = c('cohort', 'id', 'Sex', 'Condition',
                         'target_x', 'target_y'), 
              names_from = 'metric', values_from = 'diff') -> SIT_diff

SIT_raw %>%
  select(-c(id_full, Total_distance, Velocity, 
            IZ_entries, IZ_time, IZ_latency,
            Corner_entries, Corner_time)) %>%
  pivot_longer(cols = !c('cohort', 'id', 
                         'Sex', 'Condition', 'Trial_type',
                         'target_x', 'target_y'), 
               names_to = 'metric', values_to = 'values') %>%
  pivot_wider(id_cols = c('cohort', 'id', 
                          'Sex', 'Condition', 'metric',
                          'target_x', 'target_y'), 
              names_from = 'Trial_type', values_from = 'values') %>%
  group_by(metric) %>%
  mutate(NT_z = (`No Target` - mean(`No Target`, na.rm = TRUE)) / 
                          sd(`No Target`, na.rm = TRUE),
         T_z = (Target - mean(`No Target`, na.rm = TRUE)) / 
                          sd(`No Target`, na.rm = TRUE),
         z_diff = NT_z - T_z) %>%
  select(-c(`No Target`, Target)) -> SIT_z_diff

## Calculate syllable descriptives ----

# Extract coordinates for each cohort
cohorts = unique(SIT_raw$cohort)
for (cohort in cohorts) {
  print(paste('Cohort', cohort))
  syls_list = list()
  cohort_data = data[grepl(cohort, names(data))]
  for (syllable in syls_filtered$syllable) {
    print(paste('Syllable', syllable))
    syl_df = data.frame()
    for (i in names(cohort_data)) {
      runs = rle(as.vector(cohort_data[[i]]$syllables))
      syl_runs = which(runs$values == syllable)
      syl_ends = cumsum(runs$lengths)[syl_runs]
      syl_starts = (cumsum(runs$lengths)[syl_runs-1])+1
      if (length(syl_starts > 0)) {
        for (occ in c(1:length(syl_starts))) {
          centroid_x = cohort_data[[i]]$centroid[1,syl_starts[occ]:syl_ends[occ]]
          centroid_y = cohort_data[[i]]$centroid[2,syl_starts[occ]:syl_ends[occ]]
          snout_x = cohort_data[[i]]$estimated_coordinates[1,1,syl_starts[occ]:syl_ends[occ]]
          snout_y = cohort_data[[i]]$estimated_coordinates[2,1,syl_starts[occ]:syl_ends[occ]]
          torso_center_x = cohort_data[[i]]$estimated_coordinates[1,5,syl_starts[occ]:syl_ends[occ]]
          torso_center_y = cohort_data[[i]]$estimated_coordinates[2,5,syl_starts[occ]:syl_ends[occ]]
          tail_base_x = cohort_data[[i]]$estimated_coordinates[1,7,syl_starts[occ]:syl_ends[occ]]
          tail_base_y = cohort_data[[i]]$estimated_coordinates[2,7,syl_starts[occ]:syl_ends[occ]]
          shoulder_l_x = cohort_data[[i]]$estimated_coordinates[1,2,syl_starts[occ]:syl_ends[occ]]
          shoulder_l_y = cohort_data[[i]]$estimated_coordinates[2,2,syl_starts[occ]:syl_ends[occ]]
          shoulder_r_x = cohort_data[[i]]$estimated_coordinates[1,3,syl_starts[occ]:syl_ends[occ]]
          shoulder_r_y = cohort_data[[i]]$estimated_coordinates[2,3,syl_starts[occ]:syl_ends[occ]]
          torso_front_x = cohort_data[[i]]$estimated_coordinates[1,4,syl_starts[occ]:syl_ends[occ]]
          torso_front_y = cohort_data[[i]]$estimated_coordinates[2,4,syl_starts[occ]:syl_ends[occ]]
          torso_back_x = cohort_data[[i]]$estimated_coordinates[1,6,syl_starts[occ]:syl_ends[occ]]
          torso_back_y = cohort_data[[i]]$estimated_coordinates[2,6,syl_starts[occ]:syl_ends[occ]]
          heading = cohort_data[[i]]$heading[syl_starts[occ]:syl_ends[occ]]
          cbind(i, occ, centroid_x, centroid_y, snout_x, snout_y, tail_base_x, tail_base_y,
                torso_front_x, torso_front_y, torso_center_x, torso_center_y, torso_back_x, torso_back_y,
                shoulder_l_x, shoulder_l_y, shoulder_r_x, shoulder_r_y,
                heading) -> syl_coords
          syl_df = rbind(syl_df, syl_coords)
        }
      }
    }
    syl_df$i_occ = paste0(syl_df$i, '_', syl_df$occ)
    syl_df[,3:(ncol(syl_df)-1)] <- sapply(syl_df[,3:(ncol(syl_df)-1)],as.numeric)
    syls_list[[as.character(syllable)]] = syl_df
  }
  saveRDS(syls_list, paste0('Syls_descriptives_', cohort, '.rds'))
}

# Calculate descriptives for each cohort
cohorts = list.files(pattern = 'Syls_descriptives.*\\d\\d.rds')
syl_descriptives = tibble()

target_coords = SIT_raw[,c('id_full', 'Trial_type', 'target_x', 'target_y')]
target_coords$match_id = paste(SIT_raw$id_full, SIT_raw$Trial_type, sep = '_')

for (cohort in cohorts) {
  syls = readRDS(cohort)
  print(cohort)
  for (syl in names(syls)) {
    # prepare
    syls[[syl]] %>%
      mutate(center_x = 96, center_y = 96,
             target_x = target_coords$target_x[match(i, target_coords$match_id)],
             target_y = target_coords$target_y[match(i, target_coords$match_id)],
             spine_length = sqrt((torso_front_x - tail_base_x)^2 + (torso_front_y - tail_base_y)^2),
             head_length = sqrt((snout_x - torso_front_x)^2 + (snout_y - torso_front_y)^2),
             displacement = c(0, sqrt((centroid_x[-1] - centroid_x[-nrow(.)])^2 + 
                                      (centroid_y[-1] - centroid_y[-nrow(.)])^2)),
             center_dist = sqrt((centroid_x - center_x)^2 + (centroid_y - center_y)^2),
             target_dist = sqrt((snout_x - target_x)^2 + (snout_y - target_y)^2)) -> syl_dat
    
    # average
    syl_dat %>%
      group_by(i, occ) %>%
      summarise(spine_length = mean(spine_length),
                head_length = mean(head_length),
                center_dist = mean(center_dist),
                target_dist = mean(target_dist, na.rm = TRUE)) -> syl_dat_avg

    # dist, velocity, acceleration
    syl_dat %>%
      group_by(i,occ) %>%
      slice(2:n()) %>%
      summarise(total_dist = sum(displacement)) -> syl_dat_dist

    syl_dat %>%
      group_by(i, occ) %>%
      count() -> duration

    velocity = syl_dat_dist$total_dist / duration$n
    acceleration = (velocity / duration$n) * 30

    # dist to target
    syl_dat = tibble(cbind('syllable' = syl, syl_dat_avg, 
                           'total_dist' = syl_dat_dist$total_dist, 
                           'velocity' = velocity))
    syl_dat %>%
      separate(i, c('cohort', 'id', 'trial_type'), sep = '_') -> syl_dat
    syl_descriptives = rbind(syl_descriptives, syl_dat)
  }
}

syl_descriptives %>%
  pivot_longer(cols = !c('syllable', 'cohort', 'id', 'trial_type', 'occ')) %>%
  group_by(syllable, cohort, id, trial_type, name) %>%
  summarise(mean = mean(value)) %>%
syl_descriptives %>%
  mutate(name = factor(name, levels = c('total_dist', 'velocity',
                                        'spine_length', 'head_length', 
                                        'center_dist', 'target_dist'),
                             labels = c('Distance', 'Velocity',
                                        'Spine Length', 'Head Length', 
                                        'Dist. to Center','Dist. to Target')))-> syl_descriptives

## Save all as *rds filtered + with factors
# filter SI ratio < 4
# add id full for unique identifier
# order and factorize: Sex, condition, full_cond

SIT_diff %>% 
  na.omit() %>%
  filter(IZ_time < 4) %>%
  mutate(id_full = paste(cohort, id, sep = '_')) %>%
  tibble() %>%
  mutate(Sex = factor(Sex, 
                      levels = c('Male', 'Female')),
         Condition = factor(Condition,  
                            levels = c('Control','Stress'),
                            labels = c('Ctl','Stress')),
         full_cond = factor(full_cond, 
                            levels = c('Control Female','Stress Female',
                                       'Control Male', 'Stress Male'))) -> SIT_diff

SIT_z_diff %>% 
  mutate(id_full = paste(cohort, id, sep = '_')) %>%
  filter(id_full %in% SIT_diff$id_full) %>%
  tibble() %>%
  mutate(Sex = factor(Sex, 
                      levels = c('Male', 'Female')),
         Condition = factor(Condition,  
                            levels = c('Control','Stress'),
                            labels = c('Ctl','Stress')),
         full_cond = factor(paste(Condition, Sex), 
                            levels = c('Ctl Female','Stress Female',
                                       'Ctl Male', 'Stress Male'))) -> SIT_z_diff

SIT_raw %>% 
  mutate(id_full = paste(cohort, id, sep = '_')) %>%
  filter(id_full %in% SIT_diff$id_full) %>%
  tibble() %>%
  mutate(full_cond = factor(paste(Condition, Sex),
                            levels = c('Control Female','Stress Female',
                                       'Control Male', 'Stress Male')),
         Sex = factor(Sex, 
                      levels = c('Male', 'Female')),
         Condition = factor(Condition,  
                            levels = c('Control','Stress'),
                            labels = c('Ctl','Stress'))) -> SIT_raw

syl_descriptives %>% 
  mutate(id_full = paste(cohort, id, sep = '_')) %>%
  filter(id_full %in% SIT_diff$id_full) -> syl_descriptives

# Save raw and difference data frame
saveRDS(SIT_raw, 'SIT_raw_primary.rds')
saveRDS(SIT_diff, 'SIT_diff_primary.rds')
saveRDS(SIT_z_diff, 'SIT_z_primary.rds')
saveRDS(syl_descriptives, 'SIT_syl_descriptives.rds')




##### PRIMARY OFT #####

OFT <- read.csv('EthoVision_AnyMaze/primary_CSWDS_OFT_results.csv')
OFT %<>%
    mutate(id_full = paste(cohort_id, applied_ID, sep = '_'),
           cond_full = paste(Sex, Condition), 
           Center_Middle_Time = Center_Time + Middle_Time) %>%
    na.omit() %>%
    filter(Sex != '',
           Velocity < 16,
           Velocity > 2.5) %>%
    tibble()
saveRDS(OFT, 'OFT_primary.rds')




##### SECONDARY SIT #####

Sec <- read.csv('EthoVision_AnyMaze/secondary_CSDS_SIT_results.csv')
Sec$Total_distance[Sec$model == 'Urine'] <- Sec$Total_distance[Sec$model == 'Urine'] * 100
Sec$Velocity[Sec$model == 'Urine'] <- Sec$Total_distance[Sec$model == 'Urine'] / 150 

Sec %>%
  select(-c('ID')) %>%
  pivot_longer(cols = !c('cohort_id', 'applied_id', 'lab',
                         'Sex', 'Condition', 'Trial_type', 'model'), 
               names_to = 'metric', values_to = 'values') %>%
  pivot_wider(names_from = 'Trial_type', values_from = 'values') %>%
  mutate(diff = ifelse(metric %in% c('IZ_time', 'Corner_time'), 
                       Target / `No Target`, 
                       `No Target` - Target)) %>%
  select(-c(`No Target`, Target)) %>%
  pivot_wider(id_cols = c('cohort_id', 'applied_id', 'lab',
                         'Sex', 'Condition', 'model'), 
              names_from = 'metric', values_from = 'diff')   %>%
  mutate(id_full = paste(cohort_id, applied_id, sep='_')) %>%
  filter(IZ_time < 4) %>%
  rename(id = applied_id, cohort = cohort_id) -> Sec_diff

Sec_diff$Condition = factor(Sec_diff$Condition, levels = c('Control', 'Stress'), 
                            labels = c('Ctl','Stress'))
saveRDS(Sec_diff, 'SIT_diff_secondary.rds')



### END ###