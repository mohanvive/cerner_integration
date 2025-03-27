
import ballerina/http;
import ballerinax/health.clients.fhir as fhirClient;

configurable string base = ?;
configurable string tokenUrl = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string[] scopesArray = ["system/Patient.read", "system/Patient.create", "system/Observation.read"];

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

service /healthcare on new http:Listener(9090) {
    resource function get patients/[string patientName]() returns PatientSearchResponse|error {
        // Search for patients with the given name
        map<string[]> searchParameters = {
            "given": [patientName],
            "birthdate": ["gt2000-01-01"]
        };

        fhirClient:FHIRResponse searchResponse = check fhirConnectorObject->search(
            "Patient",
            searchParameters = searchParameters
        );

        // Create response
        PatientSearchResponse response = {
            httpStatusCode: searchResponse.httpStatusCode,
            patientData: <json> searchResponse.'resource
        };
        
        return response;
    }
}