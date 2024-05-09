// SPDX-License-Identifier: GPL-3.0

pragma experimental ABIEncoderV2;
pragma solidity >=0.8.4;

import "./Institution.sol";
import "./Log.sol";

contract Connector {
    string[] private institutions;
    // avoid duplicate address added the list
    mapping (string => address) private institutionName2address;

    address dateTime;

    function insertInstitution(address _institution) external{
        string memory institutionName = Institution(_institution).retrieveName();
        address institutionAddress = institutionName2address[institutionName];
        institutionName2address[institutionName] = _institution;
        if (institutionAddress == address(0)){
            institutions.push(institutionName);
            Institution(_institution).insertConnector(address(this));
        } 
    }
    
    function insertLog(address _logAddress) external{
        for (uint i = 0; i < institutions.length; i++){
            Institution(institutionName2address[institutions[i]]).insertLog(_logAddress);
        }
        Log(_logAddress).addDateTimeUtility(dateTime);
    }

    function insertDateTime(address _dateTime) external {
        dateTime = _dateTime;
        for (uint i = 0; i < institutions.length; i++){
            Institution(institutionName2address[institutions[i]]).insertDateTime(_dateTime);
        }
    }

    function retrieveAllInstitutions() external view returns(string[] memory){
        return institutions;
    }

    function retrieveInstituionaAddress(string memory institutionName) external view returns(address){
        return institutionName2address[institutionName];
    }

    function retrieveInstitutionDataConciergeAddress(string memory institutionName) external view returns(address){
        return Institution(institutionName2address[institutionName]).retrieveDataConciergeAddress();
    }


    // function retrieveDatasets() external view returns(string[] memory){
    //     string[] memory output = new string[](50);
    //     uint count = 0;
    //     for (uint i = 0; i < institutions.length; i++){
    //         Institution institution = Institution(institutionName2address[institutions[i]]);
    //         string[] memory temp = institution.retrieveDatasets();
    //         for (uint j = 0; j < temp.length; j++){
    //             output[count] = temp[j];
    //             count++;
    //         }
    //     }
    //     return output;
    // }
}