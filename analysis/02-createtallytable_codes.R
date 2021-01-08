# ##==============================================================================
# Analysis filename:			02-createtallytable-codes
# Project:				Pilot on video group clinics
# Author:					MF 
# Date: 					08/01/2020
# Version: 				R 
# Description:	Produce tally on instances of relevant codes
# Output to csv files
# Datasets used:			input.csv
# Datasets created: 		None
# Other output: tables: 'tb*.csv'			
# Log file: log-02-createtallytable.txt
# 
## ==============================================================================

## open log connection to file
sink(here::here("logs", "log-02-createtallytable.txt"))

## library
library(tidyverse)
library(here)


## import and pre-process cohort data
df_input <- read_csv(
  here::here("output", "input_codes.csv"))

df_cleaned <- df_input %>%
  mutate(GVC01_had=ifelse(is.na(GVC01_instance)|GVC01_instance==0,0,1),
         GVC02_had=ifelse(is.na(GVC02_instance)|GVC02_instance==0,0,1),
         GVC03_had=ifelse(is.na(GVC03_instance)|GVC03_instance==0,0,1),
         practice=factor(practice),
         stp=factor(stp),
         patient_id=factor(patient_id)
         )

## National tally - no. instances and no. individual patients with instances
tb01_nat_tally <- df_cleaned %>% summarise(across(where(is.numeric),~sum(.x,na.rm=T)))
tb01_nat_tally <- tb01_nat_tally %>% mutate(population=nrow(df_cleaned))
View(tb01_nat_tally)

## Practice tally - no practices with at least an instance
tb02_pratice_flags <- df_cleaned %>% group_by(practice) %>% summarise_at(vars(ends_with("had")), ~ ifelse(sum(.)>0,1,0))

## STP tally - no STPs with at least an instance
tb03_stp_flags <- df_cleaned %>% group_by(stp) %>% summarise_at(vars(ends_with("had")), ~ ifelse(sum(.)>0,1,0))


## Save
write.csv(tb01_nat_tally,paste0(here::here("output"),"/tb01_nat_tally.csv"))
write.csv(tb02_pratice_flags,paste0(here::here("output"),"/tb02_practice_flags.csv"))
write.csv(tb03_stp_flags,paste0(here::here("output"),"/tb01_stp_flags.csv"))


## close log connection
sink()
