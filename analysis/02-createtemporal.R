# ##==============================================================================
# Analysis filename:			04-createtemporal.R
# Project:				Video Group Clinics
# Author:					Heavily lifted from W. Hulme Tutorial example 3. Minor adaptations: Martina Fonseca
# Date: 					10/02/2021
# Version: 				R 
# Description:	Produce timeline of of GP consultation and VGC instance rates
# Output to csv files
# Datasets used:			various 'measures*' files
# Datasets created:  n/a		
# Other output: 	TBA		
# Log file:  logs\log-02-createtemporal.txt
# 
## ==============================================================================

## open log connection to file
sink(here::here("logs", "log-02-createtemporal.txt"))
## library
library(tidyverse)
library(here)
library(svglite)


# create directory for saving plots, if not existent
if (!dir.exists(here::here("output", "plots"))){
  dir.create(here::here("output", "plots"))
}

# create look-up table to iterate over
md_tbl <- tibble(
  measure = c("GVCcomparator","GVC_Xagrc","GVC_Y22b5","GVC_Y22b3","GVC_XaXcK"),
  measure_col=c("GVC_comparator_consult_count", "GVC_Xagrc","GVC_Y22b5","GVC_Y22b3","GVC_XaXcK"),
  measure_label = c("GPconsult", "Xagrc", "Y22b5", "Y22b3","GVC_XaXcK"),
  by = rep("practice",1,5),
  by_label = rep("by practice",1,5),
  id = paste0(measure, "_", by),
  numerator = measure,
  denominator = "population",
  group_by = rep("practice",1,5)
)

## import measures data from look-up
measures <- md_tbl %>%
  mutate(
    data = map(id, ~read_csv(here::here("output","measures", glue::glue("measure_{.}.csv")))),
  )

measures <- measures %>% mutate(no_2020_events = pmap(lst( data, measure_col), 
                                                      function(data, measure_col){
                                                        
                                                        data %>% filter(as.numeric(format(date,'%Y'))==2020) %>% select(measure_col) %>% sum()
                                                      }
)) 


#### Excluding practices with no code instances over full tenor of study period
measures <- measures %>% mutate(
  data_ori=data, # data with all practices
  data = map(data, ~ (.) %>% group_by(practice) %>% filter(sum(value,na.rm=T)>0)), # data with only practices with at least an observation in the study period (affects deciles)
  no_prac = map(data, ~(.) %>% .$practice %>% n_distinct(na.rm=T) ),
  no_prac_univ = map(data_ori, ~(.) %>% .$practice %>% n_distinct(na.rm=T))
)



quibble <- function(x, q = c(0.25, 0.5, 0.75)) {
  ## function that takes a vector and returns a tibble of quantiles - default is quartile
  tibble("{{ x }}" := quantile(x, q), "{{ x }}_q" := q)
}

v_median <- function(x) {
  tibble(median := quantile(x,0.5))
}

v_idr <- function(x){
  tibble(IDR := quantile(x,0.9)-quantile(x,0.1))
}

str_medidrnarrative <- function(mydata_idr){
  
  a<- mydata_idr %>%
    summarise(date,medchange = (median - lag(median,12))/lag(median,12)*100  ) %>% 
    mutate(classification=case_when(
      between(medchange,-15,15) ~ "no change",
      medchange>15 ~ "increase",
      medchange<(-60) ~ "large drop",
      medchange<(-15) ~ "drop",
      TRUE ~ NA_character_,
    ) )

  
  paste0("Change in median from 2019: April ",
         round(as.numeric(a[a$date=="2020-04-01","medchange"]),1),"% (",a[a$date=="2020-04-01","classification"],"); ",
         "September ",round(as.numeric(a[a$date=="2020-09-01","medchange"]),1),"% (",a[a$date=="2020-09-01","classification"],"); ",
         "December ", round(as.numeric(a[a$date=="2020-12-01","medchange"]),1),"% (",a[a$date=="2020-12-01","classification"],");")
  
}




## generate plots for each measure within the data frame
measures_plots <- measures %>% 
  mutate(
    data_quantiles = map(data, ~ (.) %>% group_by(date) %>% summarise(quibble(value, seq(0,1,0.1)),v_idr(value),v_median(value))),
    #data_median = map(data_quantiles, ~ (.) %>% group_by(date) %>% filter(value_q==0.5) %>% transmute(median=value)),
    data_idr = map(data, ~ (.) %>% group_by(date) %>% summarise(v_idr(value*1000),v_median(value*1000))),
    plot_by = pmap(lst( group_by, data, measure_label, by_label), 
                   function(group_by, data, measure_label, by_label){
                     data %>% mutate(value_1000 = value*1000) %>%
                       ggplot()+
                       geom_line(aes_string(x="date", y="value_1000", group=group_by), alpha=0.2, colour='blue', size=0.25)+
                       scale_x_date(date_breaks = "1 month", labels = scales::date_format("%Y-%m"))+
                       labs(
                         x=NULL, y=NULL, 
                         title=glue::glue("{measure_label} measurement"),
                         subtitle =  glue::glue("{by_label}, per 10,000 patients")
                       )+
                       theme_bw()+
                       theme(
                         panel.border = element_blank(), 
                         axis.line.x = element_line(colour = "black"),
                         axis.text.x = element_text(angle = 70, vjust = 1, hjust=1),
                         panel.grid.major.x = element_blank(),
                         panel.grid.minor.x = element_blank(),
                       )
                   }
    ),
    plot_quantiles = pmap(lst( group_by, data_quantiles, measure_label, by_label), 
                          function(group_by, data_quantiles, measure_label, by_label){
                            data_quantiles %>% mutate(value_1000 = value*1000) %>%
                              ggplot()+
                              geom_line(aes(x=date, y=value_1000, group=value_q, linetype=value_q==0.5, size=value_q==0.5), colour='blue')+
                              scale_linetype_manual(breaks=c(TRUE, FALSE), values=c("solid", "dotted"), guide=FALSE)+
                              scale_size_manual(breaks=c(TRUE, FALSE), values=c(1, 0.4), guide=FALSE)+
                              scale_x_date(date_breaks = "1 month", labels = scales::date_format("%Y-%m"))+
                              labs(
                                x=NULL, y=NULL, 
                                title=glue::glue("{measure_label} instances per 1000 patients"),
                                subtitle = glue::glue("quantiles {by_label}")
                              )+
                              theme_bw()+
                              theme(
                                panel.border = element_blank(), 
                                axis.line.x = element_line(colour = "black"),
                                axis.text.x = element_text(angle = 70, vjust = 1, hjust=1),
                                panel.grid.major.x = element_blank(),
                                panel.grid.minor.x = element_blank(),
                                #axis.line.y = element_blank(),
                              )
                          }
    ),
    plot_quantiles2 = pmap(lst( group_by, data_quantiles, measure_label, by_label,data_idr,no_2020_events,no_prac,no_prac_univ), 
                          function(group_by, data_quantiles, measure_label, by_label,data_idr,no_2020_events,no_prac,no_prac_univ){
                            data_quantiles %>% mutate(value_1000 = value*1000) %>%
                              ggplot()+
                              geom_line(aes(x=date, y=value_1000, group=value_q, linetype=value_q==0.5, size=value_q==0.5), colour='blue')+
                              scale_linetype_manual(breaks=c(TRUE,FALSE), values=c("solid", "dashed"), guide=FALSE,labels=c("median","decile"))+
                              scale_size_manual(breaks=c(TRUE, FALSE), values=c(1, 0.5), guide=FALSE)+
                              scale_x_date(date_breaks = "1 month", labels = scales::date_format("%Y-%m"))+
                              labs(
                                x=NULL,
                                y="rate per 1,000",
                                linetype="metric",
                                title=glue::glue("{measure_label}"),
                                subtitle = paste0(
                                  "Practices included: ",
                                  no_prac, " (",round(no_prac/no_prac_univ*100,1),"%)",
                                  "; 2020 events: ",
                                  paste0(round(no_2020_events/1000,1),"k"),
                                  "; 2020 patients: ",
                                  "TBA"
                                ),
                                caption=paste0("Feb median: ",
                                               round(data_idr %>% filter(date=="2020-02-01") %>% .$median ,1),
                                               " (IDR ",
                                               round(data_idr %>% filter(date=="2020-02-01") %>% .$IDR ,1),"), ",
                                               "April median: ",
                                               round(data_idr %>% filter(date=="2020-04-01") %>% .$median ,1),
                                               " (IDR ",
                                               round(data_idr %>% filter(date=="2020-04-01") %>% .$IDR ,1),"), ",
                                               "September median: ",
                                               round(data_idr %>% filter(date=="2020-09-01") %>% .$median ,1),
                                               " (IDR ",
                                               round(data_idr %>% filter(date=="2020-09-01") %>% .$IDR ,1),"), ",
                                               "December median: ",
                                               round(data_idr %>% filter(date=="2020-12-01") %>% .$median ,1),
                                               " (IDR ",
                                               round(data_idr %>% filter(date=="2020-12-01") %>% .$IDR ,1),")\n",
                                               str_medidrnarrative(data_idr)
                                               )
                              )+
                              theme_bw()+
                              theme(
                                panel.border = element_blank(), 
                                axis.line.x = element_line(colour = "black"),
                                axis.text.x = element_text(angle = 70, vjust = 1, hjust=1),
                                panel.grid.major.x = element_blank(),
                                panel.grid.minor.x = element_blank(),
                                axis.line.y = element_blank(),
                              )
                          }
    )
  )


## plot the charts (by variable)
measures_plots %>%
  transmute(
    plot = plot_by,
    units = "cm",
    height = 10,
    width = 15, 
    limitsize=FALSE,
    filename = str_c("plot_each_", id, ".svg"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)


## plot the charts (by quantile)
measures_plots %>%
  transmute(
    plot = plot_quantiles2,
    units = "cm",
    height = 10,
    width = 15, 
    limitsize=FALSE,
    filename = str_c("plot_quantiles_", id, ".svg"),
    path = here::here("output", "plots"),
  ) %>%
  pwalk(ggsave)


## close log connection
sink()
