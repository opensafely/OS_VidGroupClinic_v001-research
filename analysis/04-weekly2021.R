# ##==============================================================================
# Analysis filename:			04-weekly2021.R
# Project:				Pilot on group video clinics
# Author:					MF 
# Date: 					26/04/2021
# Version: 				R 
# Description:	Bring together three measures files (weekly national tally of 3 activity types). Apply redaction. Save as from OC repo.
# Output to csv files
# Datasets used:			measures_weekly* files
# Datasets created: 		None
# Other output: tables: 'tb*.csv'			
# Log file: log-04-weekly2021.txt
# 
## ==============================================================================

## open log connection to file
sink(here::here("logs", "log-04-weekly2021.txt"))


# create directory for saving tables, if not existent
if (!dir.exists(here::here("output", "tables"))){
  dir.create(here::here("output", "tables"))
}
# create directory for saving plots, if not existent
if (!dir.exists(here::here("output", "plots"))){
  dir.create(here::here("output", "plots"))
}
print("directories cleared")

## library
library(tidyverse)
library(here)
library(svglite)
`%!in%` = Negate(`%in%`)

print("Libraries loaded. Query dates established.")

## Redactor code (W.Hulme)
redactor <- function(n, threshold=6,e_overwrite=NA_integer_){
  # given a vector of frequencies, this returns a boolean vector that is TRUE if
  # a) the frequency is <= the redaction threshold and
  # b) if the sum of redacted frequencies in a) is still <= the threshold, then the
  # next largest frequency is also redacted
  n <- as.integer(n)
  leq_threshold <- dplyr::between(n, 1, threshold)
  n_sum <- sum(n)
  # redact if n is less than or equal to redaction threshold
  redact <- leq_threshold
  # also redact next smallest n if sum of redacted n is still less than or equal to threshold
  if((sum(n*leq_threshold) <= threshold) & any(leq_threshold)){
    redact[which.min(dplyr::if_else(leq_threshold, n_sum+1L, n))] = TRUE
  }
  n_redacted <- if_else(redact, e_overwrite, n)
}
print("Redactor defined")


## import and pre-process cohort data (bring together measures files)

df_input <- read_csv(here::here("output","measures-week","measure_gpc_rate.csv")) %>%
  mutate(Code="gp_consult_count") %>%
  rename(Count=gp_consult_count)

ggplot(data=df_input,aes(x=date,y=Count)) +
  geom_area(stat="identity",fill="#56B4E9") +
  facet_wrap(~region,nrow=2) +
  labs(y="Weekly instance count",title="GP consultations")+
  scale_x_date(date_breaks = "8 weeks",expand=c(0,0))  +
  theme(axis.text.x = element_text(angle = -90,vjust = 0))
ggsave(paste0(here::here("output","plots"),"/sc04_gpconsult_regtrends.svg"),width = 40, height = 30, dpi=300,units ="cm")


df_now <- read_csv(here::here("output","measures-week","measure_snomed_1092811000000108.csv")) %>%
  mutate(Code="1092811000000108") %>%
  rename(Count=snomed_1092811000000108)

ggplot(data=df_now,aes(x=date,y=Count)) +
  geom_bar(stat="identity",fill="#56B4E9") +
  facet_wrap(~region,nrow=2) +
  labs(y="Weekly instance count",title=paste0("Code: ",unique(df_now$Code)),subtitle="Participant in group consultation")+
  scale_x_date(date_breaks = "8 weeks",expand=c(0,0))  +
  theme(axis.text.x = element_text(angle = -90,vjust = 0))
ggsave(paste0(here::here("output","plots"),"/sc04_1092811000000108_regtrends.svg"),width = 40, height = 30, dpi=300,units ="cm")


df_input <- df_input %>% bind_rows(df_now)

df_now <- read_csv(here::here("output","measures-week","measure_snomed_1323941000000101.csv"))%>%
  mutate(Code="1323941000000101") %>%
  rename(Count=snomed_1323941000000101)

ggplot(data=df_now,aes(x=date,y=Count)) +
  geom_bar(stat="identity",fill="#56B4E9") +
  facet_wrap(~region,nrow=2) +
  labs(y="Weekly instance count",title=paste0("Code: ",unique(df_now$Code)),subtitle="Group consultation via video conference")+
  scale_x_date(date_breaks = "8 weeks",expand=c(0,0))  +
  theme(axis.text.x = element_text(angle = -90,vjust = 0))
ggsave(paste0(here::here("output","plots"),"/sc04_1323941000000101_regtrends.svg"),width = 40, height = 30, dpi=300,units ="cm")


df_input <- df_input %>% bind_rows(df_now)

df_now <- read_csv(here::here("output","measures-week","measure_snomed_325921000000107.csv"))%>%
  mutate(Code="325921000000107") %>%
  rename(Count=snomed_325921000000107)

ggplot(data=df_now,aes(x=date,y=Count)) +
  geom_area(stat="identity",fill="#56B4E9") +
  facet_wrap(~region,nrow=2) +
  labs(y="Weekly instance count",title=paste0("Code: ",unique(df_now$Code)),subtitle="Consultation via video conference encounter type")+
  scale_x_date(date_breaks = "4 weeks",expand=c(0,0))  +
  theme(axis.text.x = element_text(angle = -90,vjust = 0))
ggsave(paste0(here::here("output","plots"),"/sc04_325921000000107_regtrends.svg"),width = 40, height = 30, dpi=300,units ="cm")

df_input <- df_input %>% bind_rows(df_now)




# Leave only national TPP information rather than regional
df_output <- df_input %>% group_by(Code,date) %>% summarise(Count=sum(Count,na.rm=T),population=sum(population,na.rm=T)) %>% ungroup()

# Redact (<6 rule)
df_output <- df_output %>% mutate_at(vars(population,Count),redactor)

# Save redacted file
write.csv(df_output,paste0(here::here("output","tables"),"/sc04-weeklynattrend.csv")) # National weekly counts and rates of 3 codes. Redaction applied to <6.

## close log connection
sink()

