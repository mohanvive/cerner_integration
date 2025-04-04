import ballerinax/health.fhir.r4 as r4;
import ballerinax/health.fhir.r4.international401;

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

isolated function getRelationshipCode(international401:Coverage coverage) returns string {
    r4:CodeableConcept? relationship = coverage.relationship;
    if relationship is r4:CodeableConcept {
        r4:Coding[]? coding = relationship.coding;
        if coding is r4:Coding[] {
            return coding[0].code ?: "";
        }
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

isolated function getCarrierId(international401:Coverage coverage) returns string {
    r4:Identifier[]? var1 = coverage.identifier;
    if (var1 is r4:Identifier[]) {
        return var1[0].id ?: "";
    }

    return "";
}

isolated function getCode(international401:Coverage coverage) returns string {
    international401:CoverageClass[]? classResult = coverage.'class;
    if classResult is international401:CoverageClass[] {
        r4:CodeableConcept codeableConcept = classResult[0].'type;
        r4:Coding[]? coding = codeableConcept.coding;
        if coding is r4:Coding[] {
            return coding[0].code ?: "";
        }
    }

    return "";
}

isolated function getGroupValue(international401:Coverage coverage) returns string {
    international401:CoverageClass[]? classResult = coverage.'class;
    if classResult is international401:CoverageClass[] {
        return classResult[0].value;
    }

    return "";
}
