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

bp_fill_ctl = c('#FFA50095','#FFA50010','#4169E195','#4169E110')
bp_col_ctl = c('#FFA500','#FFA500','#4169E1','#4169E1')
bp_fill_str = c('#FF450095','#FF450010','#00008095','#00008010')
bp_col_str = c('#FF4500','#FF4500','#000080','#000080')

col_stress_f = c('#FFA500','#76A100','#007561')
col_stress_m = c('#4169E1','#925DC8','#C3549C')
col_stress = c(col_stress_f, col_stress_m)

col_syls = c('gray50', '#030637', '#720455', '#E95793')