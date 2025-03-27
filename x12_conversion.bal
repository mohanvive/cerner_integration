import ballerina/http; 

import wso2/health.x12.v005010 as x12;
import wso2/health.x12.v005010.a3_records as a3;
import wso2/health.x12.v005010.a1_records as a1;
import ballerina/io;

string samplex12String = string `ST*s*s*s~
    BHT*0007*13*del*del*del*18~
    HL*j*j*j*j~
    AAA*N**aaa03*aa04~
    NM1*nm01*gg*nm03*****PI*nm09~
    PER*ss*orgname*EM*per04Value*FX*per06Value*EX*pe08~
    AAA*M**aaa03-2010*aa04-2010~
    HL*j*j*j*j~
    NM1*1P*1*Smith*John*A*Mr.*XX*1234567890*s~
    AAA*M**aaa03-2010B*aa04-2010B~
    HL*2000C*2000C*2000C*2000C~
    NM1*1P*1*Smith*John*Almond*Mr.*XX*1234567890*s~
    REF*SY*10000~
    N3*49MEADOWST*APT2~
    N4*MOUNDS*OK*74047*LK~
    AAA*M**aaa03-2010C*aa04-2010C~
    DMG*D8*19700101*M~`;


service /convert on new http:Listener(9091) {
    resource function post x12ToEDI(a1:X12_005010X217_278A1 sampleX12Json) returns error|json|http:InternalServerError {
        do {
            string|error x12String = x12:x12_278_a1_to_edi_string(sampleX12Json);
            io:println("X12 EDI: ", x12String);
            return x12String;
        } on fail error err {
            // handle error
            return error("Not implemented", err);
        }
    }

    resource function post EDIToX12() returns error|json|http:InternalServerError {
        do {
            a3:X12_005010X217_278A3|error convertedx12Json = x12:from_edi_string_to_x12_278_a3(samplex12String);
            io:println("X12 JSON: ", convertedx12Json);
            return convertedx12Json;
        } on fail error err {
            // handle error
            return error("Not implemented", err);
        }
    }
}
