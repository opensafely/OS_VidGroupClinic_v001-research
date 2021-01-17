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
tb01_nat_tally <- tb01_nat_tally %>% mutate(population=nrow(df_cleaned),no_practices=n_distinct(df_cleaned$practice,na.rm=T))
#View(tb01_nat_tally)

## Practice tally - no practices with at least an instance
tb02_practice_flags <- df_cleaned %>% group_by(stp,practice) %>% summarise_at(vars(ends_with("had")), ~ ifelse(sum(.)>0,1,0))
#View(tb02_practice_flags)

tb02_practice_flags_ <- pivot_longer(tb02_practice_flags,cols=c("GVC01_had","GVC02_had","GVC03_had"),
                                     names_to="code",
                                     values_to="had_instance")

tb02_practice_flags_ <- tb02_practice_flags_ %>%
  group_by(code) %>%
  summarise(Present=sum(had_instance),Absent=n()-Present) %>%
  pivot_longer(c("Present","Absent"),names_to="Instance presence",values_to="no_practices")

tb02_practice_flags_$`Instance presence` <- factor(tb02_practice_flags_$`Instance presence`)

ggplot(tb02_practice_flags_, aes(fill=`Instance presence`,x=code, y=no_practices,label=no_practices)) +
  geom_bar( stat="identity")+
  geom_text(aes(vjust=-1),position = position_stack(vjust = 0.2))+
  theme(axis.text.x = element_text(angle = -45),text = element_text(size=17))+
  labs(title="Portion of practices with code recorded",y="Count of practices",x="Code")
#https://stackoverflow.com/questions/6644997/showing-data-values-on-stacked-bar-chart-in-ggplot2

# ggplot(tb02_practice_flags_, aes(fill=had_instance, x=code)) + 
#   geom_bar( stat="count")+
#   geom_text(stat='count', aes(label=..count..), vjust=-1)+
#   theme(axis.text.x = element_text(angle = -45),text = element_text(size=17))+
#   labs(title="Portion of practices with code recorded",y="Count of practices",x="Code")

ggsave(paste0(here::here("output"),"/sc02_fig01_practice_flags.png"),width = 40, height = 20, dpi=300,units ="cm")

## STP tally - no STPs with at least an instance
tb03_stp_flags <- df_cleaned %>% group_by(stp) %>% summarise_at(vars(ends_with("had")), ~ ifelse(sum(.)>0,1,0))
#View(tb03_stp_flags)

## Save
write.csv(tb01_nat_tally,paste0(here::here("output"),"/sc02_tb01_nat_tally.csv"))
write.csv(tb02_practice_flags,paste0(here::here("output"),"/sc02_tb02_practice_flags.csv"))
write.csv(tb03_stp_flags,paste0(here::here("output"),"/sc02_tb03_stp_flags.csv"))


## close log connection
sink()
