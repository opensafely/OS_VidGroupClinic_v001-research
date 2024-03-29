# ##==============================================================================
# Analysis filename:			01-createtallytables
# Project:				Pilot on video group clinics
# Author:					MF 
# Date: 					22/12/2020
# Version: 				R 
# Description:	Produce tally on video group clinics
# Output to csv files
# Datasets used:			input.csv
# Datasets created: 		None
# Other output: tables: 'tb*.csv'			
# Log file: log-01-createtallytable
# 
## ==============================================================================

## open log connection to file
sink(here::here("logs", "log-01-createtallytable.txt"))

## library
library(tidyverse)
library(here)


## import and pre-process cohort data
df_input <- read_csv(
  here::here("output", "input.csv"))

df_cleaned <- df_input %>%
  mutate(GroupVidClinic_had=ifelse(is.na(GroupVidClinic_instance)|GroupVidClinic_instance==0,0,1))


## Rates per characteristic

df_to_tbrates <- function(mydf,myvars,flag_save=0,tb_name="latest") {
  mytb=
    mydf %>%
    group_by_at(myvars) %>%
    summarise(
      population=n(),
      GroupVidClinic_covg=sum(GroupVidClinic_had,na.rm=T),
      GroupVidClinic_count=sum(GroupVidClinic_instance,na.rm=T),
    )
  if (flag_save){
    write.csv(mytb,paste0(here::here("output"),"/",tb_name,".csv"))
  }
  return(mytb)
}

## OC and GP rates per practice
tb01_tally_practice <- df_to_tbrates(df_cleaned,c("practice"),1,"tb01_gpcr_region") ### !!! Can we make these non pseudo_id's in cohort extractor? i.e. actual practice codes?


## OC and GP rates per STP
tb02_tally_stp <- df_to_tbrates(df_cleaned,c("stp"),1,"tb02_gpcr_stp")



## close log connection
sink()
