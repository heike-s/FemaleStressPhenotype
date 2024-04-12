### PLOTTING SETUPS 

library(ggplot2)

# General Plot Theme ----

plot_theme <- theme(axis.title=element_text(size=15,color='gray30'),
                    axis.line=element_line(color='gray30'),
                    axis.text.y=element_text(size=15,color='gray30'),
                    axis.text.x=element_text(size=15,color='gray30'),
                    legend.text=element_text(size=15),
                    legend.key.size=unit(2,'mm'),
                    panel.background=element_blank(),
                    panel.grid.major.y = element_blank(),
                    legend.position = 'none',
                    plot.margin = margin(0.5,0.5,0.5,0.5,'cm'),
                    strip.background = element_blank(),
                    strip.text = element_text(size=15,color='gray30'))

# Color palettes ----

col_full = c('#FFA500','#FF4500','#4169E1','#000080')
col_syls = c('gray50', '#030637', '#720455', '#E95793')
col_stress_f = c('#FFA500','#76A100','#007561')
col_stress_m = c('#4169E1','#925DC8','#C3549C')
