from cohortextractor import (
    codelist_from_csv,
    codelist
)

# Local codelists, query data set (MDS) - snomed (following codelistbuilder https://codelists.opensafely.org/codelist/user/martinaf/online-consultations-snomed-v01/28bba9bc/)
gvc_local_codes_snomed = codelist_from_csv(
    "codelists-local/groupvideoclinic_mds_snomed.csv", 
    system = "snomed", 
    column = "SNOMEDCode"
)


## Sociodemographics / clinical etc
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)

learning_disability_codes = codelist_from_csv(
    "codelists/opensafely-learning-disabilities.csv",
    system="ctv3",
    column="CTV3Code"
)

intellectual_disability_codes = codelist_from_csv(
    "codelists/opensafely-intellectual-disability-including-downs-syndrome.csv",
    system="ctv3",
    column="CTV3ID"
)
