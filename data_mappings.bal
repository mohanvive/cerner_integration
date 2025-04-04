import ballerina/uuid;
import ballerinax/health.fhir.r4.international401;

isolated function mapInternationPatientToCustomPatient(international401:Patient patient) returns CustomPatient => let
    string patientId = patient.id ?: uuid:createRandomUuid() in {
        id: patientId,
        firtName: patient.name.toJson(),
        birthDate: <string>patient.birthDate
    };

isolated function mapInternationCoverageToCustomCoverage(international401:Patient patient,
        international401:Coverage coverage) returns CustomCoverage => {
    benefit_code: getCode(coverage),
    coverage_end_date: coverage.period?.end ?: "",
    coverage_start_date: coverage.period?.'start ?: "",
    email: getFirstContact(patient, "email"),
    gender: patient.gender.toString(),
    carrier_id: getCarrierId(coverage),
    account_id: coverage.subscriberId ?: "",
    group_number: getGroupValue(coverage),
    is_eligible: false,
    member_age: 0,
    member_city: getCity(patient),
    member_state: getState(patient),
    member_zip: getZip(patient),
    patient_address_line_1: getAddressLine(patient),
    patient_first_name: geFirstName(patient),
    patient_last_name: geLastName(patient),
    phone: getFirstContact(patient, "phone"),
    relationship_code: getRelationshipCode(coverage),
    secondary_coverage_flag: false
};
