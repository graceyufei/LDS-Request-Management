// SPDX-License-Identifier: GPL-3.0

pragma experimental ABIEncoderV2;
pragma solidity >=0.8.4;

import "./PIManagement.sol";
import "./Log.sol";

contract DataConcierge{
    string institutionName;
    Dataset[] private datasets;
    DUA[] private DUAs;
    mapping (string => uint) private DUAnumber2dua;
    mapping (string => uint) private datasetName2dataset;

    address logAddress;

    struct Dataset {
        string name;
        string link;
        string ownerPI;
        string[] certificateRequired;
        string DUAnumber;
    }

    struct DUA {
        string DUAnumber;
        string[] signedPI;
    }


    function insertDataset(string calldata _datasetName, string calldata _link, string calldata _ownerPI, string[] calldata _certificateRequired, string calldata _DUAnumber) external{
        if(datasetName2dataset[_datasetName] == 0){
            if(_certificateRequired.length == 1 && bytes(_certificateRequired[0]).length == 0){
                datasets.push(Dataset(_datasetName, _link, _ownerPI, new string[](0), _DUAnumber));
                datasetName2dataset[_datasetName] = datasets.length;
            } else {
                datasets.push(Dataset(_datasetName, _link, _ownerPI, _certificateRequired, _DUAnumber));
                datasetName2dataset[_datasetName] = datasets.length;
            }
        }

        if (DUAnumber2dua[_DUAnumber] == 0){
            DUAs.push(DUA(_DUAnumber, new string[](0)));
            DUAnumber2dua[_DUAnumber] = DUAs.length;
        }
    }

    function insertDUA(string calldata _DUAnumber, string[] memory _signedPI) external {
        if (DUAnumber2dua[_DUAnumber] == 0){
            DUAs.push(DUA(_DUAnumber, _signedPI));
            DUAnumber2dua[_DUAnumber] = DUAs.length;
        } else {
            DUAs[DUAnumber2dua[_DUAnumber] - 1].signedPI = _signedPI;
        }
    }

    function insertLog(address _logAddress) external {
        logAddress = _logAddress;
    }

    function insertInstitutionName(string calldata _institutionName) external {
        institutionName = _institutionName;
    }


    function requestDataset(address piManagementAddress, string memory piEmail, string memory datasetName, uint timestamp) external returns(string memory){
        if (datasetName2dataset[datasetName] == 0){
            Log(logAddress).insertEntry(piEmail, institutionName, datasetName, timestamp, "N");
            return "No matching dataset.";
        }

        // 1. Check for DUA
        uint state = 0;
        string[] memory signedPI = DUAs[DUAnumber2dua[datasets[datasetName2dataset[datasetName] - 1].DUAnumber] - 1].signedPI;
        for (uint i = 0; i < signedPI.length; i++){
            if (keccak256(bytes(signedPI[i])) == keccak256(bytes(piEmail))){
                state = 1;
                break;
            }
        }

        if(state == 0){
            Log(logAddress).insertEntry(piEmail, institutionName, datasetName, timestamp, "N");
            return "DUA required.";
        }

        // 2. Check for certificate
        string[] memory certificatesRequired = datasets[datasetName2dataset[datasetName] - 1].certificateRequired;
        for (uint i = 0; i < certificatesRequired.length; i++){
            uint expirationDate = PIManagement(piManagementAddress).retrieveCertificateExpirationDate(piEmail, certificatesRequired[i]);
            if (expirationDate == 0){
                Log(logAddress).insertEntry(piEmail, institutionName, datasetName, timestamp, "N");
                return "Certificate missing";
            } else if (expirationDate < block.timestamp){
                Log(logAddress).insertEntry(piEmail, institutionName, datasetName, timestamp, "N");
                return "Certificate expired";
            }
        }
        
        // 3. Send dataset link
        Log(logAddress).insertEntry(piEmail, institutionName, datasetName, timestamp, "Y");
        return datasets[datasetName2dataset[datasetName] - 1].link;

    }

    function addPItoDUA(string memory DUAnumber, string memory PIemail) external{
        if (DUAnumber2dua[DUAnumber] == 0){
            return;
        } else {
            DUAs[DUAnumber2dua[DUAnumber] - 1].signedPI.push(PIemail);
        }
    }

    function updateDatasetLink(string memory datasetName, string memory newLink) external {
        datasets[datasetName2dataset[datasetName] - 1].link = newLink;
    }

    function retrieveSignedPI(string memory DUAnumber) external view returns(string[] memory){
        return DUAs[DUAnumber2dua[DUAnumber] - 1].signedPI;
    }

    function retrieveDataLink(string memory datasetName) external view returns(string memory){
        return datasets[datasetName2dataset[datasetName] - 1].link;
    }

    function retrieveRequiredCertificate(string memory datasetName) external view returns(string[] memory){
        return datasets[datasetName2dataset[datasetName] - 1].certificateRequired;
    }

    function retrieveRequiredCertificateLength(string memory datasetName) external view returns(uint){
        return datasets[datasetName2dataset[datasetName] - 1].certificateRequired.length;
    }
    

    function retrieveDUAnumber(string memory datasetName) external view returns(string memory){
        return datasets[datasetName2dataset[datasetName] - 1].DUAnumber;
    }

    function retrieveOwnerPIEmail(string memory datasetName) external view returns(string memory){
        return datasets[datasetName2dataset[datasetName] - 1].ownerPI;
    }    

    function retrieveDatasets() external view returns(string[] memory){
        string[] memory output = new string[](datasets.length);
        for(uint i = 0; i < datasets.length; i++){
            output[i] = datasets[i].name;
        }
        return output;
    }

}