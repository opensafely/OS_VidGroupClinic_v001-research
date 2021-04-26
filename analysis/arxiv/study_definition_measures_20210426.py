
# Import functions

from cohortextractor import (
    StudyDefinition, 
    patients, 
    codelist, 
    codelist_from_csv,
    Measure
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

    GVC_Xagrc=patients.with_these_clinical_events(
        GVC_Xagrc,    
        between = ["index_date", "index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_Y22b5=patients.with_these_clinical_events(
        GVC_Y22b5,
        between = ["index_date","index_date + 1 month"], 
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_Y22b3=patients.with_these_clinical_events(
        GVC_Y22b3,
        between = ["index_date","index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_XaXcK=patients.with_these_clinical_events(
        GVC_XaXcK,
        between = ["index_date","index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_XUkjp=patients.with_these_clinical_events(
        GVC_XUkjp,
        between = ["index_date","index_date + 1 month"],
        returning="number_of_matches_in_period",        
        return_expectations={
            "incidence": 0.1,
            "int": {"distribution": "normal", "mean": 3, "stddev": 0.5}},
    ),

    GVC_comparator_consult_count=patients.with_gp_consultations(
        between=["index_date","index_date + 1 month"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "incidence": 0.7,
        },
    ),
)

measures = [
    Measure(
        id="GVC_Xagrc_practice",
        numerator="GVC_Xagrc",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC_Y22b5_practice",
        numerator="GVC_Y22b5",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC_Y22b3_practice",
        numerator="GVC_Y22b3",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC_XaXcK_practice",
        numerator="GVC_XaXcK",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVC_XUkjp_practice",
        numerator="GVC_XUkjp",
        denominator="population",
        group_by="practice"
    ),
    Measure(
        id="GVCcomparator_practice",
        numerator="GVC_comparator_consult_count",
        denominator="population",
        group_by="practice"
    ),
]
