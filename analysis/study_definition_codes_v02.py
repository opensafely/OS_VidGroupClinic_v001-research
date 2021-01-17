
# Import functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    codelist, 
    codelist_from_csv
)

# Import codelists

GVC_local_code_01 = codelist_from_csv(
    "codelists-local/groupvideoclinic01_mds_snomed.csv",
    system="ctv3", ## [!!!!] I have set above as system="ctv3" but the codelist is "snomed". Issue is patients.with_these_clinical_events throws error with this
    column="SNOMEDCode"
)

GVC_local_code_02 = codelist_from_csv(
    "codelists-local/groupvideoclinic02_mds_snomed.csv",
    system="ctv3", ## [!!!!] I have set above as system="ctv3" but the codelist is "snomed". Issue is patients.with_these_clinical_events throws error with this
    column="SNOMEDCode"
)

GVC_local_code_03 = codelist_from_csv(
    "codelists-local/groupvideoclinic03_mds_snomed.csv",
    system="ctv3", ## [!!!!] I have set above as system="ctv3" but the codelist is "snomed". Issue is patients.with_these_clinical_events throws error with this
    column="SNOMEDCode"
)

# Specifiy study definition

start_date = "2019-07-01"
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
        start_date,
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    
    # Practice
    practice = patients.registered_practice_as_of(
         start_date,
         returning = "pseudo_id", # this is pseudo_id . not possible to return practice id
         return_expectations={
             "int": {"distribution": "normal", "mean": 100, "stddev": 20}
         },
    ),

    GVC01_instance=patients.with_these_clinical_events(
        GVC_local_code_01,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC02_instance=patients.with_these_clinical_events(
        GVC_local_code_02,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC03_instance=patients.with_these_clinical_events(
        GVC_local_code_03,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    #### CONSULTATION INFORMATION
    #
    #
    GVCcomparator_consult_count=patients.with_gp_consultations(
        between=[start_date, end_date],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": start_date, "latest": end_date},
            "incidence": 0.7,
        },
    ),
 

)
