
# Import functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    codelist, 
    codelist_from_csv,
    Measure
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
index_date = "2019-07-01"

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": start_date, "latest": "today"},
        "rate": "exponential_increase",
        "incidence":0.9,
    },

    index_date = index_date,
    # This line defines the study population
    population = patients.registered_as_of(index_date),

    # https://github.com/opensafely/risk-factors-research/issues/44
    stp=patients.registered_practice_as_of(
        index_date,
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    
    # Practice
    practice = patients.registered_practice_as_of(
         index_date,
         returning = "pseudo_id", # this is pseudo_id . not Possible to return practice id
         return_expectations={
             "int": {"distribution": "normal", "mean": 100, "stddev": 20}
         },
    ),

    GVC01_instance=patients.with_these_clinical_events(
        GVC_local_code_01,    
        between = ["index_date", "index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC02_instance=patients.with_these_clinical_events(
        GVC_local_code_02,    
        between = ["index_date","index_date + 1 month"], 
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC03_instance=patients.with_these_clinical_events(
        GVC_local_code_03,    
        between = ["index_date","index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    measures = [
    Measure(
        id="GVC02_practice",
        numerator="GVC01_instance",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC02_stp",
        numerator="GVC02_instance",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC03_practice",
        numerator="GVC03_instance",
        denominator="population",
        group_by="practice"
    ),
 

)
