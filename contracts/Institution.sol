// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.8.4;

import "./PIManagement.sol";
import "./DataConcierge.sol";

contract Institution{
    string name;
    address dataConciergeAddress;
    address piManagementAddress;

    address connector;

    constructor(string memory _name, address _piManagement, address _dataConcierge){
        name = _name;
        piManagementAddress = _piManagement;
        dataConciergeAddress = _dataConcierge;

        PIManagement(_piManagement).insertInstitutionName(_name);
        DataConcierge(_dataConcierge).insertInstitutionName(_name);
    }

    function updateInstutionName(string calldata newName) external{
        name = newName;

        PIManagement(piManagementAddress).insertInstitutionName(newName);
        DataConcierge(dataConciergeAddress).insertInstitutionName(newName);
    }

    function updateDataConcierge(address newDataConcierge) external{
        dataConciergeAddress = newDataConcierge;
    }

    function insertConnector(address _connectorAddress) external {
        connector = _connectorAddress;
        PIManagement(piManagementAddress).insertConnector(_connectorAddress);
    }

    function insertLog(address _logAddress) external {
        DataConcierge(dataConciergeAddress).insertLog(_logAddress);
    }

    function insertDateTime(address _dateTime) external {
        PIManagement(piManagementAddress).insertDateTime(_dateTime);
    }

    function retrieveName() external view returns(string memory){
        return name;
    }

    function retrieveDataConciergeAddress() external view returns(address){
        return dataConciergeAddress;
    }

    function retrievePIManagementAddress() external view returns(address){
        return piManagementAddress;
    }

    function retrieveDatasets() external view returns(string[] memory){
        return DataConcierge(dataConciergeAddress).retrieveDatasets();
    }
}