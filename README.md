# OpenSAFELY Research Template

This is a template repository for making new OpenSAFELY resarch projects.

# _Video Group Clinics Utilisation Query - for Pilot Study_

Premise: We are interested in understanding delivery of Video Group Clinics in practices. 500 practices participated in the a project piloting video group clinics and we would be interested in understanding how many video group clinics were delivered by these practices. We would also be interested in understanding delivery of video group clinics among practices that did not participate in the pilot.

Coding of Video Group Clinics is an issue, especially as non-SNOMED, hence the focus of this initial analysis is to, for now, understand the use patterns and prevalence of related codes. The coding git issue can be found [here](https://github.com/opensafely/codelist-development/issues/50).

Analysis - essentially keeping it simple and outputting via R:
* The number of instances of each code [in the last 18 months] and number of unique patients with those codes
* Number and portion of practices having used those codes at least once
* Monthly time-series [last 18 months] of code instances (+ GP consultations as trend comparator)

Other caveats from initial ask - difficult to query consultations as meaningful unit; practices cannot be extracted as identifiable.

This is the code and configuration for our paper, _Video Group Clinics Utilisation Query_

* The paper is [tba]()
* Raw model outputs, including charts, crosstabs, etc, are in `released_outputs/`
* If you are interested in how we defined our variables, take a look at the [study definition](analysis/study_definition_codes.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./local-codelists/).
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)

# About the OpenSAFELY framework

The OpenSAFELY framework is a secure analytics platform for
electronic health records research in the NHS.

Instead of requesting access for slices of patient data and
transporting them elsewhere for analysis, the framework supports
developing analytics against dummy data, and then running against the
real data *within the same infrastructure that the data is stored*.
Read more at [OpenSAFELY.org](https://opensafely.org).
