
# Import functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    codelist, 
    codelist_from_csv
)

# Import codelists

groupvideoclinic_local_codes = codelist_from_csv(
    "codelists-local/groupvideoclinic_mds_snomed.csv",
    system="ctv3", ## [!!!!] I have set above as system="ctv3" but the codelist is "snomed". Issue is patients.with_these_clinical_events throws error with this
    column="SNOMEDCode"
)

# Specifiy study definition

start_date = "2020-05-01"
end_date = "2020-12-31"

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "exponential_increase",
        "incidence":0.9,
    },
    # This line defines the study population
    population = patients.registered_as_of(start_date),

    # https://github.com/opensafely/risk-factors-research/issues/44
    stp=patients.registered_practice_as_of(
        "2020-02-01",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    
    # Practice
    practice = patients.registered_practice_as_of(
         start_date,
         returning = "pseudo_id", # this is pseudo_id . Possible to return practice id???
         return_expectations={
             "int": {"distribution": "normal", "mean": 100, "stddev": 20}
         },
    ),

    GroupVidClinic_instance=patients.with_these_clinical_events(
        groupvideoclinic_local_codes,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),
 

)
