// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.8.4;

import "./DateTime.sol";

contract Log{
    struct Entry{
        bytes piEmail;
        bytes institution;
        bytes dataset;
        uint timestamp;
        bytes answer;
    }

    Entry[] log;
    mapping(bytes => uint[]) queryLog;

    address dateTime;

    function addDateTimeUtility(address dateTimeAddress) external{
        dateTime = dateTimeAddress;
    }

    function insertEntry(string memory _piEmail, string memory _institution, string memory _dataset, uint timestamp, string memory _answer) external {
        bytes memory email = bytes(_piEmail);
        bytes memory institution = bytes(_institution);
        bytes memory dataset = bytes(_dataset);
        bytes memory answer = bytes(_answer);
        log.push(Entry(email, institution, dataset , timestamp, answer));

        bytes memory star = bytes("*");
        uint index = log.length - 1;
        // no star
        insertQuery(index, email, institution, dataset, answer);
        // one star
        insertQuery(index, star, institution, dataset, answer);
        insertQuery(index, email, star, dataset, answer);
        insertQuery(index, email, institution, star, answer);
        insertQuery(index, email, institution, dataset, star);
        // two star
        insertQuery(index, star, star, dataset, answer);
        insertQuery(index, star, institution, star, answer);
        insertQuery(index, star, institution, dataset, star);
        insertQuery(index, email, star, star, answer);
        insertQuery(index, email, star, dataset, star);
        insertQuery(index, email, institution, star, star);
        // three star
        insertQuery(index, star, star, star, answer);
        insertQuery(index, star, institution, star, star);
        insertQuery(index, star, star, dataset, star);
        insertQuery(index, email, star, star, star);
        // four star
        insertQuery(index, star, star, star, star);
    }

    function insertQuery(uint index, bytes memory _piEmail, bytes memory _institution, bytes memory _dataset, bytes memory _answer) internal{
        queryLog[abi.encodePacked(_piEmail, _institution, _dataset, _answer)].push(index);
    }


    function query(string memory piReq, string memory institutionReq, string memory datasetReq, string memory startTime, string memory endTime, string memory answer) external view returns(string memory){
        uint[] memory potential = queryLog[abi.encodePacked(bytes(piReq), bytes(institutionReq), bytes(datasetReq), bytes(answer))];
        
        uint startTimestamp = 0;
        if (!stringComparison(startTime, "*")){
            startTimestamp = DateTime(dateTime).string2uint(startTime);
        }
        uint endTimestamp = 0;
        if (!stringComparison(endTime, "*")){
            endTimestamp = DateTime(dateTime).string2uint(endTime);
        }

        bytes memory output;
        for (uint i = 0; i < potential.length; i++){
            if (withinTimeframe(potential[i], startTimestamp, endTimestamp)){
                output = abi.encodePacked(output, entryInByte(potential[i]));
            }
        }
        return string(output);
    }

    function withinTimeframe(uint logIndex, uint startTime, uint endTime) internal view returns(bool){
        uint timestamp = log[logIndex].timestamp;
        if (!(startTime == 0) && timestamp < startTime) {
            return false;
        } else if (!(endTime == 0) && timestamp > endTime) {
            return false;
        }
        return true;
    }

    function entryInByte(uint logIndex) internal view returns (bytes memory){
        bytes memory tab = bytes("_");
        bytes memory nextLine = bytes("|");
        Entry memory entry = log[logIndex];
        bytes memory temp = abi.encodePacked(entry.piEmail, tab, entry.institution, tab, entry.dataset, tab, DateTime(dateTime).uint2byte(entry.timestamp), tab, entry.answer, nextLine);
        return temp;
    }

    function stringComparison(string memory a, string memory b) internal pure returns(bool){
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

}