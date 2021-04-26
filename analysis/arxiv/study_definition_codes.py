
# Import functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    codelist, 
    codelist_from_csv
)

# Import codelists

GVC_Xagrc = codelist_from_csv(
    "codelists-local/GVC_Xagrc_ctv3.csv",
    system="ctv3",
    column="CTV3Code"
)

GVC_Y22b5 = codelist_from_csv(
    "codelists-local/GVC_Y22b5_ctv3.csv",
    system="ctv3", 
    column="CTV3Code"
)

GVC_Y22b3 = codelist_from_csv(
    "codelists-local/GVC_Y22b3_ctv3.csv",
    system="ctv3",
    column="CTV3Code"
)

GVC_XaXcK = codelist_from_csv(
    "codelists-local/GVC_XaXcK_ctv3.csv",
    system="ctv3",
    column="CTV3Code"
)

GVC_XUkjp = codelist_from_csv(
    "codelists-local/GVC_XUkjp_ctv3.csv",
    system="ctv3",
    column="CTV3Code"
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

    GVC_Xagrc=patients.with_these_clinical_events(
        GVC_Xagrc,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_Y22b5=patients.with_these_clinical_events(
        GVC_Y22b5,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_Y22b3=patients.with_these_clinical_events(
        GVC_Y22b3,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_XaXcK=patients.with_these_clinical_events(
        GVC_XaXcK,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_XUkjp=patients.with_these_clinical_events(
        GVC_XUkjp,    
        between=[start_date, end_date],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    #### CONSULTATION INFORMATION
    #
    #
    GVC_comparator_consult_count=patients.with_gp_consultations(
        between=[start_date, end_date],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": start_date, "latest": end_date},
            "incidence": 0.7,
        },
    ),
 

)
