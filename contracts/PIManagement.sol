pragma experimental ABIEncoderV2;
pragma solidity >=0.8.4;

import "./DataConcierge.sol";
import "./DateTime.sol";
import "./Connector.sol";


contract PIManagement{
    string institutionName;

    PI[] PIs;
    mapping(string => uint) piEmail2PI;
    mapping(string => Certificate[]) piemail2certificates;

    mapping(bytes => string) request2output;

    struct PI {
        string name;
        string email;
    }


    struct Certificate{
        string name;
        uint expirationDate;
    }

    address dateTimeAddress;
    address connectorAddress;

    function insertInstitutionName(string calldata _institutionName) external{
        institutionName = _institutionName;
    }

    function insertConnector(address _connector) external{
        connectorAddress = _connector;
    }

    function insertDateTime(address _dateTimeAddress) external{
        dateTimeAddress = _dateTimeAddress;
    }

    function insertPI(string calldata piName, string calldata piEmail) external{
        PIs.push(PI(piName, piEmail));
        piEmail2PI[piEmail] = PIs.length;
    }

    function requestData(string memory piEmail, string memory datasetInstitutionName, string memory datasetName, uint timestamp) external{
        address dataConciergeAddress = Connector(connectorAddress).retrieveInstitutionDataConciergeAddress(datasetInstitutionName);
        bytes memory key = abi.encodePacked(bytes(piEmail), bytes(datasetInstitutionName), bytes(datasetName), DateTime(dateTimeAddress).uint2byte(timestamp));
        request2output[key] = DataConcierge(dataConciergeAddress).requestDataset(address(this), piEmail, datasetName, timestamp);
    }

    function getData(string memory piEmail, string memory datasetInstitutionName, string memory datasetName, uint timestamp) external view returns(string memory){
        bytes memory key = abi.encodePacked(bytes(piEmail), bytes(datasetInstitutionName), bytes(datasetName), DateTime(dateTimeAddress).uint2byte(timestamp));
        return request2output[key];
    }

    function signDUA(string memory piEmail, string memory datasetInstitutionName, string memory DUAnumber) external{
        address dataConciergeAddress = Connector(connectorAddress).retrieveInstitutionDataConciergeAddress(datasetInstitutionName);
        DataConcierge(dataConciergeAddress).addPItoDUA(DUAnumber, piEmail);
    }

    function insertNewCertificate(string memory piEmail, string calldata certificateName, string memory expirationDate) external{
        uint _expirationDate = DateTime(dateTimeAddress).convertDate2Timestamp(bytes(expirationDate));
        piemail2certificates[piEmail].push(Certificate(certificateName, _expirationDate));
    }

    function retrieveName() external view returns(string memory){
        return institutionName;
    }

    function retrieveCertificateExpirationDate(string memory piEmail, string memory certificateName) external view returns (uint){
        Certificate[] memory temp = piemail2certificates[piEmail];
        uint expirationTime = 0;
        for (uint i = 0; i < temp.length; i++){
            if (keccak256(bytes(temp[i].name)) == keccak256(bytes(certificateName)) && temp[i].expirationDate > expirationTime){
                expirationTime = temp[i].expirationDate;
            }
        }
        return expirationTime;
    }

}
