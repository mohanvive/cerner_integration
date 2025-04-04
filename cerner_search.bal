import ballerina/http;
import ballerina/io;
import ballerinax/health.clients.fhir as fhirClient;
import ballerinax/health.fhir.r4 as r4;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4.parser as fhirParser;

configurable string base = ?;
configurable string tokenUrl = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string[] scopesArray = ["system/Patient.read", "system/Patient.create", "system/Observation.read", "system/Coverage.read"];

// Create a FHIR client configuration
fhirClient:FHIRConnectorConfig cernerConfiuration = {
    baseURL: base,
    mimeType: fhirClient:FHIR_JSON,
    authConfig: {
        tokenUrl: tokenUrl,
        clientId: clientId,
        clientSecret: clientSecret,
        scopes: scopesArray
    }
};

// Create a FHIR client
final fhirClient:FHIRConnector fhirConnectorObject = check new (cernerConfiuration);

type PatientSearchResponse record {|
    int httpStatusCode;
    json patientData;
|};

type CustomPatient record {
    string id;
    json firtName;
    string birthDate;
};

type PatientInput record {
    string memberId;
    string firtName;
    string lastName;
    string birthDate;
};

type CustomCoverage record {
    string benefit_code;
    string coverage_end_date;
    string coverage_start_date;
    string email;
    string gender;
    string carrier_id;
    string account_id;
    string group_number;
    boolean is_eligible;
    int member_age;
    string member_city;
    string member_state;
    string member_zip;
    string[] patient_address_line_1;
    string[] patient_first_name;
    string patient_last_name;
    string phone;
    string relationship_code;
    boolean secondary_coverage_flag;
};

service /healthcare on new http:Listener(9090) {

    resource function get patients/[string patientName]() returns PatientSearchResponse|error {

        // Search for patients with the given name and birth date
        map<string[]> searchParameters = {
            "given": [patientName],
            "birthdate": ["gt2000-01-01"]
        };

        fhirClient:FHIRResponse searchResponse = check fhirConnectorObject->search(
            "Patient",
            searchParameters = searchParameters
        );

        // Create response - updated
        PatientSearchResponse response = {
            httpStatusCode: searchResponse.httpStatusCode,
            patientData: <json>searchResponse.'resource
        };

        return response;
    }

    resource function get patients/custom/[string patientName]() returns CustomPatient[]|error {

        // Search for patients with the given name and birth date
        map<string[]> searchParameters = {
            "given": [patientName],
            "birthdate": ["gt2000-01-01"]
        };

        fhirClient:FHIRResponse searchResponse = check fhirConnectorObject->search(
            "Patient",
            searchParameters = searchParameters
        );

        json inputJson = <json>searchResponse.'resource;
        r4:Bundle fhirBundle = check fhirParser:parse(inputJson).ensureType();
        r4:BundleEntry[] entries = fhirBundle.entry ?: [];

        CustomPatient[] customPatientEntries = [];
        foreach var entry in entries {
            international401:Patient patient = check entry?.'resource.cloneWithType();
            CustomPatient CustomPatient = mapInternationPatientToCustomPatient(patient);
            customPatientEntries.push(CustomPatient);
        }

        return customPatientEntries;
    }

    resource function post coverage(PatientInput patient) returns json|error {

        // Search for patients with the encounter ID
        map<string[]> searchParameters = {
            "-encounter": ["97953483"]
        };

        fhirClient:FHIRResponse searchResponse = check fhirConnectorObject->search(
            "Coverage",
            searchParameters = searchParameters
        );

        json inputJson = <json>searchResponse.'resource;
        r4:Bundle fhirBundle = check fhirParser:parse(inputJson).ensureType();
        r4:BundleEntry[] entries = fhirBundle.entry ?: [];
        international401:Coverage coverage = check entries[0]?.'resource.cloneWithType();

        io:println(coverage);
        return <json>coverage;
    }

    resource function post coverage/eligibility(PatientInput patientInput) returns json|CustomCoverage|error {

        // Search for patients with the given id 
        map<string[]> patientSearchParameters = {
            "_id": [patientInput.memberId]
        };

        fhirClient:FHIRResponse patientSearchResponse = check fhirConnectorObject->search(
            "Patient",
            searchParameters = patientSearchParameters
        );

        json inputJson = <json>patientSearchResponse.'resource;

        r4:Bundle fhirBundle = check fhirParser:parse(inputJson).ensureType();
        r4:BundleEntry[] entries = fhirBundle.entry ?: [];
        international401:Patient patient = check entries[0]?.'resource.cloneWithType();

        io:println(patient);

        map<string[]> coverageSearchParameters = {
            "patient": [patientInput.memberId]
        };

        fhirClient:FHIRResponse coverageSearchResponse = check fhirConnectorObject->search(
            "Coverage",
            searchParameters = coverageSearchParameters
        );

        inputJson = <json>coverageSearchResponse.'resource;
        fhirBundle = check fhirParser:parse(inputJson).ensureType();
        entries = fhirBundle.entry ?: [];
        international401:Coverage coverage = check entries[0]?.'resource.cloneWithType();

        io:println(coverage);
        return mapInternationCoverageToCustomCoverage(patient, coverage);

    }
}

