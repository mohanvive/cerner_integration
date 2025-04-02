import ballerina/http;
import ballerina/io;
import ballerina/uuid;
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

        // json|error entries = inputJson.entry;
        // if entries is json {
        //     if entries is json[] {
        //         foreach var item in entries {
        //             // var ss = {"fullUrl":"https://fhir-ehr-code.cerner.com/r4/ec2458f2-1e24-41c8-b71b-0e701af7583d/Patient/12803002","resource":{"resourceType":"Patient","id":"12803002","meta":{"versionId":"0","lastUpdated":"2022-08-04T18:33:42.000Z"},"text":{"status":"generated"},"identifier":[{"id":"CI-490995427-0","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"2","display":"Community Medical Record Number","userSelected":true},{"system":"http://terminology.hl7.org/CodeSystem/v2-0203","code":"MR","display":"Medical record number","userSelected":false}],"text":"Community Medical Record Number"},"system":"urn:oid:2.16.840.1.113883.3.787.0.0","value":"53156","_value":{"extension":[{"valueString":"53156","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}},{"id":"CI-490995431-1","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"10","display":"MRN","userSelected":true},{"system":"http://terminology.hl7.org/CodeSystem/v2-0203","code":"MR","display":"Medical record number","userSelected":false}],"text":"MRN"},"system":"urn:oid:2.16.840.1.113883.6.1000","value":"61145","_value":{"extension":[{"valueString":"00000061145","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}},{"id":"CI-490995429-2","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"2553236785","display":"MIllennium Person Identifier","userSelected":true}],"text":"MIllennium Person Identifier"},"_system":{"extension":[{"valueCode":"unknown","url":"http://hl7.org/fhir/StructureDefinition/data-absent-reason"}]},"value":"69404","_value":{"extension":[{"valueString":"69404","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}}],"active":true,"name":[{"id":"CI-12803002-0","use":"official","text":"DC-TEST, John","family":"DC-TEST","given":["John"]}],"gender":"male","birthDate":"2009-09-09"},"search":{"mode":"match"}};
        //             io:println(item);
        //             international401:Patient patient = check fhirParser:parse(check item.'resource).ensureType();
        //             // uscore501:USCorePatientProfile patient = check fhirParser:parse(item, uscore501:USCorePatientProfile).ensureType();
        //             io:println(patient);
        //         }
        //     }
        // }

        // json inputJson = <json> searchResponse.'resource;
        // json|error entries = inputJson.entry;
        // if entries is json {
        //     if entries is json[] {
        //         foreach var item in entries {
        //             json ss = {"fullUrl":"https://fhir-ehr-code.cerner.com/r4/ec2458f2-1e24-41c8-b71b-0e701af7583d/Patient/12803002","resource":{"resourceType":"Patient","id":"12803002","meta":{"versionId":"0","lastUpdated":"2022-08-04T18:33:42.000Z"},"text":{"status":"generated"},"identifier":[{"id":"CI-490995427-0","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"2","display":"Community Medical Record Number","userSelected":true},{"system":"http://terminology.hl7.org/CodeSystem/v2-0203","code":"MR","display":"Medical record number","userSelected":false}],"text":"Community Medical Record Number"},"system":"urn:oid:2.16.840.1.113883.3.787.0.0","value":"53156","_value":{"extension":[{"valueString":"53156","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}},{"id":"CI-490995431-1","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"10","display":"MRN","userSelected":true},{"system":"http://terminology.hl7.org/CodeSystem/v2-0203","code":"MR","display":"Medical record number","userSelected":false}],"text":"MRN"},"system":"urn:oid:2.16.840.1.113883.6.1000","value":"61145","_value":{"extension":[{"valueString":"00000061145","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}},{"id":"CI-490995429-2","use":"usual","type":{"coding":[{"system":"https://fhir.cerner.com/ec2458f2-1e24-41c8-b71b-0e701af7583d/codeSet/4","code":"2553236785","display":"MIllennium Person Identifier","userSelected":true}],"text":"MIllennium Person Identifier"},"_system":{"extension":[{"valueCode":"unknown","url":"http://hl7.org/fhir/StructureDefinition/data-absent-reason"}]},"value":"69404","_value":{"extension":[{"valueString":"69404","url":"http://hl7.org/fhir/StructureDefinition/rendered-value"}]},"period":{"start":"2022-08-04T18:33:42.000Z"}}],"active":true,"name":[{"id":"CI-12803002-0","use":"official","text":"DC-TEST, John","family":"DC-TEST","given":["John"]}],"gender":"male","birthDate":"2009-09-09"},"search":{"mode":"match"}};

        //             io:println(ss);
        //             international401:Patient patient = check fhirParser:parse(ss).ensureType();
        //             io:println(patient);
        //         }
        //     }
        // }

        // json outputJson = check jsondata:read(inputJson, `$.entry[*].resource.given`);
        // io:print(outputJson);

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

        // Search for patients with the given name, last name and 
        // map<string[]> patientSearchParameters = {
        //     "given": [patientInput.firtName],
        //     "name": [patientInput.lastName],
        //     "birthdate": [patientInput.birthDate]
        // };

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
            "-encounter": ["97953483"]
        };

        fhirClient:FHIRResponse coverageSearchResponse = check fhirConnectorObject->search(
            "Coverage",
            searchParameters = coverageSearchParameters
        );

        inputJson = <json>coverageSearchResponse.'resource;
        fhirBundle = check fhirParser:parse(inputJson).ensureType();
        entries = fhirBundle.entry ?: [];
        international401:Coverage coverage = check entries[0]?.'resource.cloneWithType();

        return mapInternationCoverageToCustomCoverage(patient, coverage);

    }
}

isolated function mapInternationPatientToCustomPatient(international401:Patient patient) returns CustomPatient => let
    string patientId = patient.id ?: uuid:createRandomUuid() in {
        id: patientId,
        firtName: patient.name.toJson(),
        birthDate: <string>patient.birthDate
    };

isolated function mapInternationCoverageToCustomCoverage(international401:Patient patient,
        international401:Coverage coverage) returns CustomCoverage => {
    benefit_code: "",
    coverage_end_date: "",
    coverage_start_date: "",
    email: getFirstContact(patient, "email"),
    gender: patient.gender.toString(),
    carrier_id: "",
    account_id: "",
    group_number: "",
    is_eligible: false,
    member_age: 0,
    member_city: getCity(patient),
    member_state: getState(patient),
    member_zip: getZip(patient),
    patient_address_line_1: getAddressLine(patient),
    patient_first_name: geFirstName(patient),
    patient_last_name: geLastName(patient),
    phone: getFirstContact(patient, "phone"),
    relationship_code: "",
    secondary_coverage_flag: false
};

isolated function getCity(international401:Patient patient) returns string {
    r4:Address[]? var1 = patient.address;
    if (var1 is r4:Address[]) {
        return var1[0].city ?: "";
    }

    return "";
}

isolated function getZip(international401:Patient patient) returns string {
    r4:Address[]? var1 = patient.address;
    if (var1 is r4:Address[]) {
        return var1[0].postalCode ?: "";
    }

    return "";
}

isolated function getState(international401:Patient patient) returns string {
    r4:Address[]? var1 = patient.address;
    if (var1 is r4:Address[]) {
        return var1[0].state ?: "";
    }

    return "";
}

isolated function getAddressLine(international401:Patient patient) returns string[] {
    r4:Address[]? var1 = patient.address;
    if (var1 is r4:Address[]) {
        return var1[0].line ?: [];
    }

    return [];
}

isolated function getRelationshipCode(international401:Patient patient) returns string {
    r4:Address[]? var1 = patient.address;
    if (var1 is r4:Address[]) {
        return var1[0].state ?: "";
    }

    return "";
}

isolated function getFirstContact(international401:Patient patient, string contactType) returns string {
    r4:ContactPoint[]? contactPoints = patient.telecom;
    if (contactPoints is r4:ContactPoint[]) {
        foreach var contactPoint in contactPoints {
            if contactPoint.system == contactType {
                return contactPoint.value ?: "";
            }
        }
    }

    return "";
}

isolated function geFirstName(international401:Patient patient) returns string[] {
    r4:HumanName[]? var1 = patient.name;
    if (var1 is r4:HumanName[]) {
        return var1[0].given ?: [];
    }

    return [];
}

isolated function geLastName(international401:Patient patient) returns string {
    r4:HumanName[]? var1 = patient.name;
    if (var1 is r4:HumanName[]) {
        return var1[0].family ?: "";
    }

    return "";
}
